//
// Created by Wildog on 12/2/19.
// Copyright (c) 2019 Wildog. All rights reserved.
//

import UIKit
import Moya
import ReactiveCocoa
import ReactiveSwift
import MMKV

/// API服务基础协议
///
/// 服务的通常实现方式为
/// ```
/// enum XXService: APIService {}
/// ```
/// 针对服务下的每个 API 返回不同的 route、servicePath、parameters等
protocol APIService: TargetType {
    
    /// 完整的 URL，该字段无特殊需求不需要具体服务实现
    var url: URL { get }
    
    /// API 路由和 HTTP 方法，不包含域名、服务名和版本号，
    ///
    /// 如一个 GET API 完整地址为 http://xx.com/message/v1/group/create
    /// 这里返回
    /// ```
    /// .get("/group/create")
    /// ```
    var route: APIRoute { get }
    
    /// API 服务路径          // 旧版接口servicePath传空字符串“”，这种格式 /v1/message/group/create
    /// 新版才使用servicePath
    /// 如一个 GET API 完整地址为 http://xx.com/message/v1/group/create
    /// 这里返回
    /// ```
    /// "/message"
    /// ```
    var servicePath: String { get }
    
    /// API 请求参数
    ///
    /// `APIParameter` 实现了 `ExpressibleByDictionaryLiteral`，
    /// `parameters` 的返回值可以直接以 `[String: Any?]` 形式返回，
    /// *nil 值的字段会被自动忽略掉*
    var parameters: APIParameters? { get }
    
    /// 版本号
    ///
    /// 默认为 "/v1"
    var version: String? { get }
    
    /// 热插件
    ///
    /// 默认为 []
    var hotPlugins: [APIPlugin] { get }
    
    /// 默认为 “application/json”
    var contentType: String? { get }

    /// 能否在短时间内重复请求
    var needCancelRepeatRequest: Bool { get }
}

extension APIService {

    var baseURL: URL {
        URL(string: Env.current.constants.baseUrl + servicePath)!
    }
    
    var servicePath: String {
        ""
    }
    
    var version: String? {
        "/v1"
    }

    var route: APIRoute {
        fatalError("route has not been implemented")
    }
    
    /// HTTP 请求头
    var headers: [String: String]? {
        [
            "Accept": "*/*"
//            "Content-Type": "application/x-www-form-urlencoded; application/json; text/plain"
        ]
    }
    
    var contentType: String? {
        nil
    }
    
    func makeHeaders() -> [String: String]? {
        var headers = self.headers ?? ["Accept": "application/json;application/x-www-form-urlencoded"]
        if method == .get || method == .head || method == .delete {
            headers["Content-Type"] = contentType ?? "application/json"
        } else {
            headers["Content-Type"] = contentType ?? "application/x-www-form-urlencoded"
        }
        return headers
    }
    
    /// 响应码校验
    ///
    /// 默认只接受 200 的响应码作为成功响应
    var validationType: ValidationType {
        ValidationType.customCodes([200])
    }

    /// mock 数据
    ///
    /// 当 APIProvider 请求时携带了 `.stub()` 行为时，
    /// `sampleData` 不需要提供
    var sampleData: Data {
        fatalError("sampleData has not been implemented")
    }

    var url: URL {
        self.defaultURL
    }

    var defaultURL: URL {
        self.path.isEmpty ? self.baseURL : self.baseURL.appendingPathComponent(self.path)
    }

    var path: String {
        NSString.path(withComponents: [version ?? "/v1", self.route.path])
    }

    var method: Moya.Method {
        self.route.method
    }

    var parameters: APIParameters? {
        nil
    }
    
    var hotPlugins: [APIPlugin] {
        []
    }
    
    var task: Task {
        guard let params = self.parameters?.values else {
            return .requestPlain
        }
        let defaultEncoding: ParameterEncoding = self.method == .get ? URLEncoding.queryString : APIParamEncoding.default
        return .requestParameters(parameters: params, encoding: self.parameters?.encoding ?? defaultEncoding)
    }
    
    var identifier: String {
        route.method.rawValue + url.absoluteString
    }
    
    var requestIdentifier: String {
        var identifier = ""
        identifier += "url=\(path)"
        identifier += "&method=\(method.rawValue)"
        if let dict = parameters?.values {
            let keys = dict.keys.sorted()
            for key in keys {
                identifier += String(format: "&%@=%@", key, String(describing: dict[key]))
            }
        }
        identifier = identifier.md5()
        return identifier
    }
    
    var needCancelRepeatRequest: Bool {
        return false
    }
}

/// `APIProviderSharing` 为所有的 `APIService` 提供了一个
/// `APIProvider` 的单例用于执行请求和管理内部状态
protocol APIProviderSharing where Self: APIService {
    static var shared: APIProvider<Self> { get }
//    func make(_ duringOfObject: AnyObject?, behaviors: Set<APIRequestBehavior>?, hotPlugins: [APIPlugin]) -> SignalProducer<APIResult, APIError>
}

extension APIService where Self: APIProviderSharing {
    /**
     语法糖，本质是调用当前 `APIService` 的 `APIProvider` 单例
     来执行请求，参数说明参见 `APIProvider`
     */
    static func `do`(_ api: Self, behaviors: Set<APIRequestBehavior>? = nil, hotPlugins: [APIPlugin] = [], within: AnyObject? = nil) -> SignalProducer<APIResult, APIError> {
        Self.shared.make(api, behaviors: behaviors, hotPlugins: hotPlugins, within: within)
    }
    
//    /// 构造网络请求，将 API 转换为 SignalProducer
//    /// 记得加上 duringOfObject，一般为控制器本身(传 self 就行)，控制请求的生命周期
//    func make(_ duringOfObject: AnyObject?, behaviors: Set<APIRequestBehavior>? = nil, hotPlugins: [APIPlugin] = []) -> SignalProducer<APIResult, APIError> {
//        Self.shared.make(self, behaviors: behaviors, hotPlugins: hotPlugins, within: duringOfObject)
//    }
}

/// `APICallable` 为具体类提供了快速调用 API 的语法糖，
/// 并将 API 请求的生命周期和调用者保持一致，
/// 所有的 NSObject 均实现了该协议
protocol APICallable: AnyObject {
    /**
     语法糖，本质是调用当前 `T` 的 `APIProvider` 单例
     来执行请求，并将请求的生命周期和调用者绑定在一起，
     常用于 Controllers 执行请求， 参数说明参见 `APIProvider`
     */
    func `do`<T: APIProviderSharing>(_ api: T, behaviors: Set<APIRequestBehavior>?, hotPlugins: [APIPlugin], within: AnyObject?) -> SignalProducer<APIResult, APIError>
}

extension NSObject: APICallable {}

extension APICallable {
    func `do`<T: APIProviderSharing>(_ api: T, behaviors: Set<APIRequestBehavior>? = nil, hotPlugins: [APIPlugin] = [], within: AnyObject? = nil) -> SignalProducer<APIResult, APIError> {
        T.do(api, behaviors: behaviors, hotPlugins: hotPlugins, within: within ?? self)
    }
}
