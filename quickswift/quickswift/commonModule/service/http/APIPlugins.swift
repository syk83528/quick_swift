//
//  APIPlugins.swift
//  spsd
//
//  Created by Wildog on 12/4/19.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import common
import Moya
import ReactiveSwift
import CryptoSwift
import MMKV

/// API 业务插件
///
/// 使用请参见 `APIProvider` 的 `apiPlugins`、`hotPlugins` 或者 `APIService` 的 `hotPlugins`
protocol APIPlugin {
    
    /**
     请求开始执行时调用
     
     - Parameters:
        - api: API
        - behaviors: 指定的行为，参考 `APIRequestBehavior`
     */
    func didStart(api: TargetType, _ behaviors: Set<APIRequestBehavior>?)

    /**
     请求结束时调用
     
     - Parameters:
         - api: API
         - behaviors: 指定的行为，参考 `APIRequestBehavior`
         - response: 解析后的响应
         - error: 解析后的错误
     */
    func didEnd(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult?, _ error: APIError?)
    
    /**
     收到响应后调用，在这里处理校验逻辑，如判断通用的错误码等，将响应解析并抛出错误
     
     - Parameters:
         - api: API
         - behaviors: 指定的行为，参考 `APIRequestBehavior`
         - response: 解析后的响应
     
     - Returns:
       如有错误则抛出

     */
    func validate(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult) -> APIError?
    
}

extension APIPlugin {
    
    func didStart(api: TargetType, _ behaviors: Set<APIRequestBehavior>?) {}
    
    func didEnd(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult?, _ error: APIError?) {}
    
    func validate(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult) -> APIError? { nil }
    
}

/// 网络层插件，参数加密、签名和 headers 注入
final class RequestTransformation: PluginType {
    
    private func buildTimeout(_ request: inout URLRequest, target: TargetType) {
        if let _ = target as? APIService,
           let behaviors = request.behaviors,
           let timeoutBehavior = behaviors.first(where: { $0 == .customTimeout(0) }),
           case let .customTimeout(timeout) = timeoutBehavior,
           timeout != nil && timeout! > 0 {
            request.timeoutInterval = timeout!
        } else {
            request.timeoutInterval = 15
        }
    }
    
    private func buildParams(_ request: inout URLRequest, target: TargetType) -> Dict {
        let timestamp: String = String(ServerTime.millisecond)
        
        var body: Dict = Dict()
        // get, head, delete query params in URI
        // 可能是 Moya的bug？？ 把 delete 的参数放到 body 里了
        // 还是咱们后台的设计问题？把 delete 的参数放到 url 里了
        if target.method == .get || target.method == .head {
            if let params = request.url?.params {
                guard JSONSerialization.isValidJSONObject(params) else {
                    llogWarning("[http]: is invalid json object: \(params)")
                    return body
                }
                body = params
            }
        } else {
            body = ((try? JSONSerialization.jsonObject(with: request.httpBody ?? Data(), options: .mutableContainers)) as? [String: Any]) ?? [String: Any]()
        }
        #if DEBUG || TEST
        let requestParams = body
        request.addValue(requestParams.toJSONString() ?? "faile to load request params.", forHTTPHeaderField: "requestParams")
//        if AppManager.shared.appendHeaders.keys.count > 0 {
//            for headers in AppManager.shared.appendHeaders {
//                guard "\(headers.value)".count > 0 else { continue }
//                request.addValue("\(headers.value)", forHTTPHeaderField: headers.key)
//            }
//        }
        #endif
//        body.merge(from: AppManager.globalParams)
        body["timestamp"] = timestamp
//        if let token = UserManager.current?.token, !token.isEmpty {
//            body["token"] = token
//        }
        
        // 推广渠道
//        if let obj = UserDefaults.standard.object(forKey: kOpenInstallDataKey) as? Dict {
//            if let channel = (obj["channelCode"] ?? obj["openinstallChannelCode"]) as? String {
//                body["ditchNo"] = channel // 推广渠道
//            }
//        }
        return body
    }
    
    private func buildSign(_ request: inout URLRequest, target: TargetType, params: Dict) throws {
        // 参与签名的参数
        guard let sign = params.toJSONString()?.base64Encode else { return }
        
        let env = Env.current.constants
        
        // AES-128, ECB, PKCS7
        let aes = try AES(key: Array(env.key.utf8), blockMode: ECB(), padding: .pkcs7)
        let ciphertext = try aes.encrypt(Array(sign.utf8))
        
        let cipherBase64 = ciphertext.toBase64()
        
        // Customize characters that do not need to be escaped
        var set = CharacterSet()
        set.formUnion(.uppercaseLetters)
        set.formUnion(.lowercaseLetters)
        set.formUnion(.decimalDigits)
        set.formUnion(.init(charactersIn: "[]."))
        // escaped
        set.formIntersection(.init(charactersIn: ":/?&=;+!@#$()~',*"))
        
        let encodedText = cipherBase64.addingPercentEncoding(withAllowedCharacters: set) ?? ""
        if (target.method == .get || target.method == .head || target.method == .delete),
            let values = request.url?.absoluteString.components(separatedBy: "?"),
           values.last?.isEmpty == false,
            let requestUrlString = values.first
        {
            request.url = URL(string: requestUrlString + "?params=\(encodedText)")
        } else {
            request.httpBody = "params=\(encodedText)".data(using: .utf8)
        }
        
        #if ENVS
        // remove request params
//        var globalParams = params
//        for key in params.keys {
//            globalParams.removeValue(forKey: key)
//        }
        request.addValue(AppManager.globalParams.toJSONString() ?? "faile to load globalParams params.", forHTTPHeaderField: "globalParams")
        #endif
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let _ = target as? APIService else {
            return request
        }
        
        var finalRequest = request
        
        // timeout
        buildTimeout(&finalRequest, target: target)
        
        // params
        let body: Dict = buildParams(&finalRequest, target: target)
        
#if DEBUG || TEST
        let env = Env.current.constants
        if let url = request.url, url.host != env.baseUrl.url?.host {
            return request
        }
#endif
        do {
            try buildSign(&finalRequest, target: target, params: body)
            return finalRequest
        } catch {
            llog("[http]: request encrypt error.")
            return finalRequest
        }
    }
    
}

/// 业务层插件，处理状态栏网络请求图标的显示和隐藏
final class NetworkIndicatorHandler: APIPlugin {
    
     enum NetworkIndicatorChangeType {
        case began, ended
    }

    typealias NetworkIndicatorClosure = (_ change: NetworkIndicatorChangeType) -> Void
    
    static var requestsInflight: Int = 0
    
    static let shared = NetworkIndicatorHandler { action in
        switch action {
        case .began:
            requestsInflight += 1
        case .ended:
            requestsInflight -= 1
        }
        Common.Queue.main {
            UIApplication.shared.isNetworkActivityIndicatorVisible = requestsInflight > 0
        }
    }
    
    let networkActivityClosure: NetworkIndicatorClosure

    init(networkActivityClosure: @escaping NetworkIndicatorClosure) {
        self.networkActivityClosure = networkActivityClosure
    }

    func didStart(api: TargetType, _ behaviors: Set<APIRequestBehavior>?) {
        guard behaviors?.contains(.hideActivityIndicator) == true else {
            networkActivityClosure(.began)
            return
        }
    }
    
    func didEnd(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult?, _ error: APIError?) {
        guard behaviors?.contains(.hideActivityIndicator) == true else {
            networkActivityClosure(.ended)
            return
        }
    }
}

/// 业务层插件，处理通用业务错误，弹出错误提示、踢出弹窗等
final class ToastErrorHandler: APIPlugin {
    static let shared = ToastErrorHandler()
    
    func didEnd(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult?, _ error: APIError?) {
        guard let error = error else { return }
        var shouldEmitToast = true
        var shouldBalance = true
        if let behaviors = behaviors {
            for behavior in behaviors {
                if case let .suppressMessage(codes) = behavior {
                    if let codes = codes {
                        if codes.contains(error.errorCode) {
                            // suppress specific codes
                            shouldEmitToast = false
                        }
                        //是否外部处理余额不足弹框
                        if codes.contains(APIError.balanceCode) {
                            shouldBalance = false
                        }
                    } else {
                        // suppress all message
                        shouldEmitToast = false
                    }
                    break
                }
            }
        }
        if case let .balance(message) = error, shouldBalance {
            ToastErrorHandler.showBalanceAlert(message: message)
//        } else if case .kickout = error, api.path != LoginAPI.logout.path {
//            Toast("请重新登录后再试", style: .fatal).show()
//            UserManager.shared.logout()
        } else if case let .gameClose(message) = error {
            ToastErrorHandler.showGameOpenAlert(message: message)
        } else if case let .notVIP(message) = error {
            ToastErrorHandler.showNotVIPAlert(message: message)
//        } else if case let .kickout(message) = error {
//            if api.path != LoginAPI.logout.path {
//                UserManager.shared.logout()
//            }
//            // TODO: LoginAPI.logout
//            Common.Delay.execution(delay: 0.5) {
//                Alert(message, confirmTitle: "知道了", cancelTitle: nil, identifier: "登录过期，请重新登录").show()
//            }
        } else {
            /// 保险起见 在此再做一次判断，以免code遗漏
            if error.errorCode == APIError.kickoutCode || error.errorCode == APIError.shouldReloginCode {
                UserManager.logout()
            }
            if error.errorCode == -6 {
                return
            }
            if shouldEmitToast {
                Common.Queue.main {
                    llog(error.localizedDescription + " \nError code: \(error.errorCode)")
                    Toast(error.localizedDescription, style: .alert).show()
//                    Toast(error.localizedDescription + " \nError code: \(error.errorCode)", style: .alert).show()
                }
            }
        }
    }
    
    static func showBalanceAlert(message: String? = "", title: String? = "") {
        Toast("余额不足").show()
    }
    
    static func showGameOpenAlert(message: String? = "", title: String? = "") {
//        let msg = message.count > 0 ? message : "请先开通"
//        Alert(msg, title: title, confirmTitle: "去开通").then({
//            $0.identifier = message
//        }).show(confirmAction: { (_) -> Bool in
//            LeisureController.push(["userId": UserManager.current?.userId ?? ""], animated: true)
//            return true
//        })
    }
    
static func showNotVIPAlert(message: String? = "还不是 VIP, 请开通后再试", title: String = "不是VIP") {
//        let msg = message ?? "还不是 VIP, 请开通后再试"
//        Alert(msg, title: title, confirmTitle: "前往开通").then({
//            $0.identifier = message
//        }).show(confirmAction: { (_) -> Bool in
//            Notif.overlayShouldDismiss.post()
//            Notif.GiftPicker.dismiss.post()
//            VIPCenterVC.push()
//            return true
//        })
    }
}

/// 业务层插件，如果响应的 ext 中包含 IM 配置，连接到对应 IM
final class IMConnector: APIPlugin {
    func didEnd(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult?, _ error: APIError?) {
        guard let ext = response?.ext else { return }
        
        // 配置 IM endPoint, 连接已改为手动触发（在 MainViewController -> ViewDidLoad 中)
    }
}

/// 业务层插件，解析ext里的最新余额更新到本地
final class BalanceHandler: APIPlugin {
    static let shared = BalanceHandler()
    
    func didEnd(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult?, _ error: APIError?) {
        guard let ext = response?.ext, let currentUser = UserManager.current else { return }
        
//        var balanceUpdated = false
//        if let beans = ext["gainCoin"].int64 { // 豆
//            currentUser.beans = beans
//            balanceUpdated = true
//        }
//        if let coin = ext["rechargeCoin"].int64 { // 充值的币
//            currentUser.coin = coin
//            balanceUpdated = true
//        }
//        if let freeBeans = ext["sendGainCoin"].int64 { // 赠送的币
//            currentUser.freeBeans = freeBeans
//            balanceUpdated = true
//        }
//        if let ownRoom = ext["ownChatRoom"].bool {
//            currentUser.isCreatedChatRoom = ownRoom
//            Notif.Room.createRoomStatusUpdate.post()
//        }
//        if balanceUpdated {
//            currentUser.save()
//            Notif.User.balanceDidChange.post()
//        }
    }
}

/// 业务层插件，校验响应、处理业务错误并抛出
class APIResponseValidation: APIPlugin {
    
    typealias ResponseValidateClosure = (Set<APIRequestBehavior>?, APIResult) -> APIError?
    
    static let shared = APIResponseValidation()
    
    let validationClosure: ResponseValidateClosure?
    
    init(validation: @escaping ResponseValidateClosure = APIResponseValidation.defaultValidation) {
        validationClosure = validation
    }
    
    static func defaultValidation(behaviors: Set<APIRequestBehavior>?, response: APIResult) -> APIError? {
        APIError(from: response)
    }
    
    func validate(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult) -> APIError? {
        guard let validation = validationClosure else {
            return nil
        }
        return validation(behaviors, response)
    }
}

/// 业务层插件，在请求前后添加副作用
///
/// 可用 `init(start:end:)` 快速创建，适合用做单次请求或者 `APIService` 的热插件传入 `hotPlugins`
class APIResponseSideEffect: APIPlugin {
    
    typealias APIStartClosure = (Set<APIRequestBehavior>?) -> Void
    typealias APIEndClosure = (Set<APIRequestBehavior>?, APIResult?, APIError?) -> Void
    
    let startClosure: APIStartClosure?
    let endClosure: APIEndClosure?
    
    init(start: APIStartClosure? = nil, end: APIEndClosure? = nil) {
        startClosure = start
        endClosure = end
    }
    
    func didStart(api: TargetType, _ behaviors: Set<APIRequestBehavior>?) {
        startClosure?(behaviors)
    }
    
    func didEnd(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult?, _ error: APIError?) {
        endClosure?(behaviors, response, error)
    }
}

/// 业务层插件，记录、矫正本地时间和服务端时间的偏差
final class ServerTime: APIPlugin {
    
    public static let shared = ServerTime()
    private static let timeOffsetKey: String = "ServerTime.offset"
    
    private init() {
        timeOffset = MMKV.default()?.int64(forKey: Self.timeOffsetKey) ?? 0
        UIApplication.willTerminateNotification.listen(duringOf: self).observeValues { _ in
            MMKV.default()?.set(self.timeOffset, forKey: ServerTime.timeOffsetKey)
        }
    }
    
    public static var millisecond: Int64 {
        get {
            Int64(Date().timeIntervalSince1970 * 1000) + shared.timeOffset
        }
        set {
            guard newValue > 0 else { return }
            let localTime: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
            shared.timeOffset = newValue - localTime
        }
    }
    
    public static var date: Date {
        Date(timeIntervalSinceNow: Double(shared.timeOffset) / 1000)
    }
    
    private var timeOffset: Int64 = 0
    
    func didEnd(api: TargetType, _ behaviors: Set<APIRequestBehavior>?, _ response: APIResult?, _ error: APIError?) {
        if let response = response, let millisecond = response.timestamp {
            Self.millisecond = millisecond
        } else if case let .timeOffset(serverTime, _) = error, let millisecond = serverTime {
            Self.millisecond = millisecond
        } else if case let .moyaError(moyaError) = error,
            case let .underlying(_, moyaResponse) = moyaError,
            let statusCode = moyaResponse?.statusCode,
            statusCode == 408 {
            Self.millisecond = Int64(Date().timeIntervalSince1970 * 1000)
        }
    }
}

/// Logs network activity (outgoing requests and incoming responses).
public final class NetworkLoggingPlugin: PluginType {
    fileprivate let loggerId = "Moya_Logger"
    fileprivate let separator = ", "
    fileprivate let terminator = "\n"
    fileprivate let cURLTerminator = "\\\n"
    fileprivate let output: (_ separator: String, _ terminator: String, _ items: Any...) -> Void
    fileprivate let requestDataFormatter: ((Data) -> (String))?
    fileprivate let responseDataFormatter: ((Data) -> (Data))?
    
    /// A Boolean value determing whether response body data should be logged.
    public let isVerbose: Bool
    public let cURL: Bool
    
    /// Initializes a NetworkLoggerPlugin.
    public init(verbose: Bool = false, cURL: Bool = false, output: ((_ separator: String, _ terminator: String, _ items: Any...) -> Void)? = nil, requestDataFormatter: ((Data) -> (String))? = nil, responseDataFormatter: ((Data) -> (Data))? = nil) {
        self.cURL = cURL
        self.isVerbose = verbose
        self.output = output ?? NetworkLoggerPlugin.reversedPrint
        self.requestDataFormatter = requestDataFormatter
        self.responseDataFormatter = responseDataFormatter
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
//#if DEBUG || TEST
//        guard KVStore[.debugLogRequest, true] else { return }
//#endif
//
//        Common.Queue.async {
//            if let request = request as? CustomDebugStringConvertible, self.cURL {
//                self.output(self.separator, self.terminator, request.debugDescription)
//                return
//            }
//            self.outputItems(self.logNetworkRequest(request.request as URLRequest?))
//        }
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
//#if DEBUG || TEST
//        guard KVStore[.debugLogResponse, true] else { return }
//#endif
//
//        Common.Queue.async {
//            switch result {
//            case let .success(response):
//                self.outputItems(self.logNetworkResponse(response.response, data: response.data, target: target))
//            case let .failure(error):
//                var response: HTTPURLResponse?
//                switch error {
//                case let .statusCode(resp):
//                    response = resp.response
//                case let .underlying(_, resp):
//                    response = resp?.response
//                default:
//                    break
//                }
//                self.outputItems(self.logNetworkResponse(response, data: nil, target: target))
//            }
//        }
    }
    
    fileprivate func outputItems(_ items: [String]) {
        if isVerbose {
            items.forEach { output(separator, terminator, $0) }
        } else {
            output(separator, terminator, items)
        }
    }
}

#if DEBUG
private let dateFormatter = DateFormatter().then {
    $0.dateFormat = "[dd/MM/yyyy HH:mm:ss.SSS]"
    $0.locale = Locale(identifier: "en_US_POSIX")
}
#endif

private extension NetworkLoggingPlugin {
    
    var date: String {
#if DEBUG
        return dateFormatter.string(from: Date())
#else
        return ""
#endif
    }
    
    func format(_ loggerId: String, date: String, identifier: String, message: String) -> String {
        return "\(identifier) \(date) \(message)"
    }
    
    func logNetworkRequest(_ request: URLRequest?) -> [String] {
        
        var output = [String]()
        
//        output += [format(loggerId, date: date, identifier: "🌐 [Network]", message: "\n<\(String(repeating: "-", count: 14))Starting\(String(repeating: "-", count: 15))")]
//
//        let requestPath = request?.url?.absoluteString.replace(request?.url?.query ?? "", to: "").remove("?")
//        let isGet = request?.httpMethod == "GET"
//        var requestString = "Request \(request?.httpMethod ?? ""):\n" + (requestPath ?? "(invalid request)")
//
//        if var headers = request?.allHTTPHeaderFields {
//            headers.removeValue(forKey: "globalParams")
//            headers.removeValue(forKey: "requestParams")
//            requestString += "\nRequest Header:\n" + headers.description
//        }
//
//        if let bodyStream = request?.httpBodyStream {
//            requestString += "\nRequest Body Stream:\n" + bodyStream.description
//        }
//
//        if isGet == false, let body = request?.httpBody, let stringOutput = requestDataFormatter?(body) ?? String(data: body, encoding: .utf8), isVerbose {
//            requestString += "\nRequest Body:\n" + stringOutput
//        }
//        if let globalParams = request?.allHTTPHeaderFields?["globalParams"], let gParamsJson = globalParams.parseJSON() as? Dict, isVerbose {
//            requestString += "\nRequest Global Params:\n" + (gParamsJson.toJSONString(prettyPrint: true) ?? "invalid globalParams json value.")
//        }
//        if let requestParams = request?.allHTTPHeaderFields?["requestParams"], let rParamsJson = requestParams.parseJSON() as? Dict, isVerbose {
//            requestString += "\nRequest Request Params:\n" + (rParamsJson.toJSONString(prettyPrint: true) ?? "invalid requestParams json value.")
//        }
//
//        output += [requestString]
        
        return output
    }
    
    func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: TargetType) -> [String] {
        guard let response = response else {
            return [
                format(loggerId, date: date, identifier: "⚠️ [Network]", message: "\n\(String(repeating: "-", count: 15))Response\(String(repeating: "-", count: 14))>"),
                "Received empty network response for \(target)."
            ]
        }
        
        var output = [String]()
        
        output += [format(loggerId, date: date, identifier: "🌈 [Network]", message: "\n\(String(repeating: "-", count: 15))Response\(String(repeating: "-", count: 14))>")]
        
        if let data = data, let stringData = String(data: responseDataFormatter?(data) ?? data, encoding: String.Encoding.utf8), isVerbose {
            var urlString = ""
            if let url = response.url {
                urlString = "\(target.method), " + url.scheme.or("") + "://" + (url.host ?? "") + url.path
            }
            output += [urlString, stringData]
        } else {
            output += [format(loggerId, date: date, identifier: "Response", message: response.description)]
        }
        
        return output
    }
}

fileprivate extension NetworkLoggerPlugin {
    static func reversedPrint(_ separator: String, terminator: String, items: Any...) {
        for item in items {
//            log(item, separator: separator, terminator: terminator)
        }
    }
}
