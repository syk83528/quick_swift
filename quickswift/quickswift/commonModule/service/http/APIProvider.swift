//
// Created by Wildog on 12/2/19.
// Copyright (c) 2019 Wildog. All rights reserved.
//

import UIKit
import Moya
import ReactiveSwift
import HandyJSON

// fileprivate let apiRequestScheduler = QueueScheduler(qos: .default, name: "com.duomi.api.request.scheduler", targeting: nil)
fileprivate let apiRequestQueue = DispatchQueue.init(label: "com.duomi.api.request.queue", qos: .userInitiated, target: nil)
/// 单次 API 请求的执行行为
enum APIRequestBehavior: Equatable, Hashable, CustomStringConvertible {
    
    /**
     隐藏状态栏左上角的网络请求图标，
     当一些请求并非用户主动触发时使用，
     如获取配置、上报日志等
     */
    case hideActivityIndicator
    
    /**
     报错后不弹出错误信息
     
     常用于：
     - 执行一些非用户主动出发的请求
     - 请求错误不影响正常的业务流程
     - 服务端报的特定错误码有特定的处理逻辑，不需要展示通用的错误信息吐司
     
     - Parameters:
       - codes: 指定不弹出错误信息的错误码
     */
    case suppressMessage(_ codes: [Int]? = nil)
    
    /**
     mock 数据
     
     用于开发过程中服务端接口未开发完成，本地造假数据用
     
     - Parameters:
       - delay: 响应延迟
       - result: 返回假数据的 closure
     */
    case stub(_ delay: TimeInterval? = nil, _ result: (() -> [String: Any])? = nil)
    
    /**
     自定义请求超时时间
     
     默认为 15s
     */
    case customTimeout(TimeInterval? = nil)
    
    /**
     失败后重试
     
     - Parameters:
        - upTo: 最多重试次数
        - maxInterval: 两次重试间的时间间隔，backoff 策略
        - when: 根据 error 判断是否需要重试，参见 `APIError.retry()`
     */
    case retry(upTo: Int = 3, maxInterval: TimeInterval = 3, when: ((Error) -> Bool) = APIError.retryTest())
    
    static let requestBehaviorsKey = "behaviors"
    static let requestBehaviorsSeparator = "|||"
    static let requestBehaviorParamSeparator = ","
    
    /**
     快速创建一个返回列表数据的 .stub()
     
     - Parameters:
        - list: 列表数据，若 T 遵循 HandyJSON，列表元素会自动转成 JSON 字典
        - delay: 响应延迟
     */
    static func stub<T>(list: @escaping () -> [T], delay: TimeInterval = 1.5) -> APIRequestBehavior {
        return .stub(dict: {
            return ["list": list().map({ (obj) -> Any in
               if let json = obj as? HandyJSON {
                   return (json.toJSON() ?? obj) as Any
               }
               return obj
            })]
        }, delay: delay)
    }
    
    /**
     快速创建一个返回 result 数据的 .stub()
     
     - Parameters:
        - dict: result
        - delay: 响应延迟
     */
    static func stub(dict: @escaping () -> [String: Any], delay: TimeInterval = 1.5) -> APIRequestBehavior {
        return .stub(delay, { ["code": 200, "result": dict()] })
    }
    
    init?(_ string: String) {
        let components = string.components(separatedBy: Self.requestBehaviorParamSeparator)
        guard let behavior = components.first else {
            return nil
        } 
        switch behavior {
        case APIRequestBehavior.hideActivityIndicator.caseName:
            self = .hideActivityIndicator
        case APIRequestBehavior.suppressMessage().caseName:
            self = .suppressMessage()
        case APIRequestBehavior.stub().caseName:
            self = .stub(components.last.or("0").interval)
        case APIRequestBehavior.customTimeout().caseName:
            self = .customTimeout(components.last.or("15").interval)
        case APIRequestBehavior.retry().caseName:
            self = .retry()
        default:
            return nil
        }
    }
    
    public var description: String {
        var params = [caseName]
        switch self {
        case let .stub(delay, _):
            params += ["\(delay ?? 0)"]
        case let .customTimeout(timeout):
            params += ["\(timeout ?? 15)"]
        default:
            break
        }
        return params.joined(separator: Self.requestBehaviorParamSeparator)
    }
    
    public var shouldInjectToHeader: Bool {
        switch self {
        case .customTimeout, .stub:
            return true
        default:
            return false
        }
    }
    
    public var caseName: String {
        switch self {
        case .hideActivityIndicator:
            return "hideActivityIndicator"
        case .suppressMessage:
            return "suppressMessage"
        case .stub:
            return "stub"
        case .customTimeout:
            return "customTimeout"
        case .retry:
            return "retry"
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(caseName)
    }

    public static func == (lhs: APIRequestBehavior, rhs: APIRequestBehavior) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension URLRequest {

    var behaviors: Set<APIRequestBehavior>? {
        guard let bhs = self.allHTTPHeaderFields?[APIRequestBehavior.requestBehaviorsKey] else {
            return nil
        }
        var behaviors = Set<APIRequestBehavior>()
        for bh in bhs.components(separatedBy: APIRequestBehavior.requestBehaviorsSeparator) {
            if let b = APIRequestBehavior(bh) {
                behaviors.insert(b)
            }
        }
        return behaviors
    }
}

class APIEndpoint: Endpoint {
    
    let behaviors: Set<APIRequestBehavior>?
    
    init(target: APIService, behaviors: Set<APIRequestBehavior>?) {
        self.behaviors = behaviors
        var sampleResponseClosure: SampleResponseClosure
        if let stubBehavior = behaviors?.first(where: { $0 == .stub() }),
            case let .stub(_, sampleDict) = stubBehavior, let jsonClosure = sampleDict {
            let json = jsonClosure()
            let data = try? JSONSerialization.data(withJSONObject: json)
            sampleResponseClosure = { .networkResponse(200, data ?? target.sampleData) }
        } else {
            sampleResponseClosure = { .networkResponse(200, target.sampleData) }
        }
        
        super.init(url: target.url.absoluteString, sampleResponseClosure: sampleResponseClosure, method: target.method, task: target.task, httpHeaderFields: target.makeHeaders())
    }
    
    func makeRequest() throws -> URLRequest {
        var request = try super.urlRequest()
        if let bhs = behaviors, bhs.count > 0 {
            let bhsString = Array(bhs).map({ $0.description }).joined(separator: APIRequestBehavior.requestBehaviorsSeparator)
            request.addValue(bhsString, forHTTPHeaderField: APIRequestBehavior.requestBehaviorsKey)
        }
        return request
    }
}

struct APIProviderContext {
    var headerInjectedBehaviorsMap = [String: Set<APIRequestBehavior>]()
}

private var providerContext = APIProviderContext()

/// 一个 API 服务的实际执行类
///
/// 用于一个 API 服务下的各个请求及管理内部状态
/// `APIService` 实现了 `APIProviderSharing`，
/// 默认会为每个服务提供一个 `shared` 的 APIProvider 单例
class APIProvider<Target: TargetType>: MoyaProvider<Target> {

    let apiPlugins: [APIPlugin]
    
    /**
     构造方法
     
     - Parameters:
        - endpointClosure: 将一个 APIService 下的 Target 转换成可执行的 Endpoint，使用默认值即可
        - requestClosure: 将一个 Endpoint 转成 URLRequest，使用默认值即可
        - stubClosure: 将 mock 数据转成 Response Data，使用默认值即可
        - callbackQueue: 回调线程，默认为主线程
        - manager: Alamofire Manager，使用默认值即可
        - plugins: Moya 的 PluginType 插件，作用于整个服务，一般用于网络层的参数加解密、校验和 headers 注入等
        - apiPlugins: 业务层的 `APIPlugin` 插件，作用于整个服务
        - trackInflights: 防止重复请求，重复请求的实际网络请求只会发出去一次，各个调用者的回调会正常收到
     */
    init(
        endpointClosure: @escaping EndpointClosure = APIProvider<Target>.APIEndpointClosure,
        requestClosure: @escaping RequestClosure = APIProvider<Target>.APIRequestMapping,
        stubClosure: @escaping StubClosure = APIProvider<Target>.APIStubClosure,
        callbackQueue: DispatchQueue? = nil,// apiRequestQueue,
//        manager:  Manager = APIProvider<Target>.defaultAlamofireManager(),
        plugins: [PluginType] = APIProvider<Target>.defaultPlugins,
        apiPlugins: [APIPlugin] = APIProvider<Target>.defaultAPIPlugins,
        trackInflights: Bool = true
    ) {
        self.apiPlugins = apiPlugins
        super.init(
                endpointClosure: endpointClosure,
                requestClosure: requestClosure,
                stubClosure: stubClosure,
                callbackQueue: callbackQueue,
                plugins: plugins,
                trackInflights: trackInflights
        )
    }

    /**
     默认的业务层插件
     
     默认实现包含插件:
        - `APIResponseValidation`: 解析、校验响应中的业务错误并抛出
        - `ServerTime`: 矫正本地时间
        - `BalanceHandler`: 解析ext里的最新余额更新到本地
        - `ToastErrorHandler`: 处理通用业务错误，弹出错误提示、踢出弹窗等
        - `NetworkIndicatorHandler`: 处理状态栏左上角的网络请求图标的显示和隐藏
     */
    static var defaultAPIPlugins: [APIPlugin] {
        [
            APIResponseValidation.shared,
            ServerTime.shared,
            BalanceHandler.shared,
            ToastErrorHandler.shared,
            NetworkIndicatorHandler.shared
        ]
    }

    /**
     默认的网络层插件
     
     默认实现包含插件:
        - `RequestTransformation`: 请求参数加密、header 签名注入等
        - `NetworkLoggingPlugin`: Debug 时打印日志
     */
    static var defaultPlugins: [PluginType] {
        #if DEBUG || TEST
        return [
            RequestTransformation(),
            NetworkLoggingPlugin(verbose: true, responseDataFormatter: APIProvider<Target>.ResponseLoggingDataFormatter)
        ]
        #else
        return [
            RequestTransformation()
        ] as [PluginType]
        #endif
    }
    
    static func ResponseLoggingDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }

    static func APIStubClosure(target: Target) -> StubBehavior {
        if let target = target as? APIService, let stubBehavior = providerContext.headerInjectedBehaviorsMap[target.identifier]?.first(where: { $0 == .stub() }) {
            if case let .stub(delay, _) = stubBehavior, delay != nil && delay! > 0 {
                return .delayed(seconds: delay!)
            }
            return .immediate
        }
        return .never
    }
    
    static func APIEndpointClosure(target: Target) -> Endpoint {
        if let apiTarget = target as? APIService {
            return APIEndpoint(target: apiTarget, behaviors: providerContext.headerInjectedBehaviorsMap[apiTarget.identifier])
        }
        return MoyaProvider.defaultEndpointMapping(for: target)
    }
    
    static func APIRequestMapping(for endpoint: Endpoint, closure: RequestResultClosure) {
        do {
            var urlRequest: URLRequest
            if let apiEndpoint = endpoint as? APIEndpoint {
                urlRequest = try apiEndpoint.makeRequest()
            } else {
                urlRequest = try endpoint.urlRequest()
            }
            closure(.success(urlRequest))
        } catch MoyaError.requestMapping(let url) {
            closure(.failure(MoyaError.requestMapping(url)))
        } catch MoyaError.parameterEncoding(let error) {
            closure(.failure(MoyaError.parameterEncoding(error)))
        } catch {
            closure(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    /**
     创建一个请求的 SignalProducer
     
     - Parameters:
        - api: API
        - behaviors: 请求行为，参见 `APIRequestBehavior`
        - hotPlugins: 热插件，只对本次请求生效
        - within: 将请求的生命周期和对象的生命周期绑定
     
     - Returns:
        请求的 SignalProducer，信号值为解析后的响应数据 `APIResult`，错误为解析后的 `APIError`
     */
    func make(_ api: Target, behaviors: Set<APIRequestBehavior>? = nil, hotPlugins: [APIPlugin] = [], within: AnyObject? = nil) -> SignalProducer<APIResult, APIError> {
        var pluginApplied = apiPlugins + hotPlugins
        if let apiServiceTarget = api as? APIService {
            pluginApplied += apiServiceTarget.hotPlugins
        }
        
        // stub, timeout injected
        var originalSignalProducer = self.reactive.request(api)
        if let api = api as? APIService,
            let injections = behaviors?.filter({ $0.shouldInjectToHeader }), injections.count > 0 {
            let identifier = api.identifier
            originalSignalProducer = originalSignalProducer.on(starting: {
                providerContext.headerInjectedBehaviorsMap[identifier] = injections
            }, started: {
                providerContext.headerInjectedBehaviorsMap[identifier] = nil
            })
        }
        
        // decoded
        var responseMapped = originalSignalProducer
//            .observe(on: apiRequestScheduler)
//            .map { (response) -> Moya.Response in
//            let decodedResponse = Moya.Response(statusCode: response.statusCode, data: response.data, request: response.request, response: response.response)
//            return decodedResponse
//        }
            .map(APIResult.self)
//        #if TEST || !DEBUG
        responseMapped = responseMapped.observe(on: UIScheduler())
//        #endif
        
        // getaway retry
        let errorMapped = responseMapped.mapError { APIError(from: $0) }.retry(when: {
            if case .timeOffset = $0 {
                // 客户端和服务端有时间差时，经过ServerTime Plugin校准后，
                // 应该默认重试一次
                llog("Local tilme has been re-synced to server time")
                return true
            }
            return false
        }, upTo: 1, interval: 1)
        
        // validated
        var validated = errorMapped.attempt { (response: APIResult) -> Result<(), APIError> in
            let errors = pluginApplied.compactMap({ $0.validate(api: api, behaviors, response) })
            if errors.count > 0 {
                return .failure(errors.sorted(by: <).first!)
            }
            return .success(())
        }
        
        // biz retry
        if case let .retry(upTo, interval, when) = behaviors?.first(where: {
            if case .retry = $0 {
                return true
            }
            return false
        }) {
            validated = validated.retry(when: when, upTo: upTo, interval: interval)
        }
        
        // plugins
        var lifetimeObserved = validated.on(started: {
            DispatchQueue.main.async {
                pluginApplied.forEach { $0.didStart(api: api, behaviors) }
            }
        }, failed: { (error: APIError) in
            DispatchQueue.main.async {
                pluginApplied.forEach { $0.didEnd(api: api, behaviors, nil, error) }
            }
            #if DEBUG
            llog(error)
            #endif
        }, interrupted: {
            DispatchQueue.main.async {
                pluginApplied.forEach { $0.didEnd(api: api, behaviors, nil, nil) }
            }
        }, value: { (response: APIResult) in
            DispatchQueue.main.async {
                pluginApplied.forEach { $0.didEnd(api: api, behaviors, response, nil) }
            }
        })

        if let context = within {
            lifetimeObserved = lifetimeObserved.take(duringLifetimeOf: context)
        }
        

        return lifetimeObserved
    }
}
