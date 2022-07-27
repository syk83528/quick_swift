//
//  APIError.swift
//  spsd
//
//  Created by Wildog on 12/4/19.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import Moya
import common

/// 错误优先级
enum ErrorPriority: Comparable, CustomStringConvertible {
    
    case low(Int? = 0)
    case normal(Int? = 0)
    case high(Int? = 0)
    
    static func < (lhs: ErrorPriority, rhs: ErrorPriority) -> Bool {
        switch (lhs, rhs) {
        case let (.high(lv), .high(rv)),
             let (.normal(lv), .normal(rv)),
             let (.low(lv), .low(rv)):
            return lv! > rv!
        default:
            return lhs.basePriority < rhs.basePriority
        }
    }
    
    var basePriority: Int {
        switch self {
        case .high:
            return 0
        case .normal:
            return 1
        case .low:
            return 2
        }
    }
    
    var description: String {
        switch self {
        case let .low(value):
            return "[Priority: Low, \(value ?? 0)]"
        case let .normal(value):
            return "[Priority: Normal, \(value ?? 0)]"
        case let .high(value):
            return "[Priority: High, \(value ?? 0)]"
        }
    }
}

/// 带有优先级的错误
///
/// - 使用场景：
///   例如请求的 `hotPlugins` 中有多个在 `validate()` 中会抛错的插件，
///   调用层将收到优先级最高的错误
protocol PrioritizedError {
    var priority: ErrorPriority { get }
    static func < (lhs: Self, rhs: Self) -> Bool
}

extension PrioritizedError {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.priority < rhs.priority
    }
}

/// 错误码转换
///
/// 用于在特定场景下通过错误码转换错误类型，
/// 可参考实现了 `ErrorCodeConvertible` 的 `APIError`、`IMError`
protocol ErrorCodeConvertible {
    var errorCode: Int { get }
    init?(errorCode: Int)
}

/// 可重试的错误
protocol RetryTestable {
    /// 在调用层声明操作出错时需要重试时，
    /// 判断特定错误是否可以重试
    var shouldRetry: Bool { get }
}

extension RetryTestable {
    var shouldRetry: Bool { false }
}

/// 网关层错误
///
/// 一般包裹在 APIError.getawayError() 中
enum GetawayError: Int, RawRepresentable, LocalizedError, CustomStringConvertible, CustomDebugStringConvertible {
    // 网关层错误码 (MoyaError 时)
    case getawayInvalidParam = 400
    case getawayInvalidSign = 401
    case getawayBlocked = 403
    case getawayNotFound = 404
    case getawayMethodError = 405
    case getawayTimeout = 408
    case getawayServerError = 503
    
    var description: String {
        switch self {
        case .getawayInvalidParam:
            return "参数无效" + debug(info: ", HTTP Error: 400")
        case .getawayInvalidSign:
            return "参数签名无效" + debug(info: ", HTTP Error: 401")
        case .getawayBlocked:
            return "你已被屏蔽" + debug(info: ", HTTP Error: 403")
        case .getawayNotFound:
            return "服务器开小差了，请稍后再试" + debug(info: ", HTTP Error: 404")
        case .getawayTimeout:
            return "网关请求超时" + debug(info: ", HTTP Error: 408")
        case .getawayMethodError:
            return "网关方法错误" + debug(info: ", HTTP Error: 405")
        case .getawayServerError:
            return "服务器不可用" + debug(info: ", HTTP Error: 503")
        }
    }
    
    var debugDescription: String {
        "\(rawValue): \(description)"
    }
}

/// 网络层错误
///  
/// 封装 Moya 错误、数据映射错误、网关错误、业务错误等
enum APIError: Swift.Error, LocalizedError, PrioritizedError, ErrorCodeConvertible, CustomStringConvertible, CustomDebugStringConvertible, RetryTestable {
    
    /// 客户端网络层错误
    case moyaError(MoyaError)
    
    /// 数据处理、映射时错误
    case mappingError(APIResult)
    
    /// 网关错误
    case getawayError(GetawayError)
    
    // 业务层错误
    /**
     通用业务层错误，通常吐司弹出告知用户即可
     
     - Parameters:
     - $0: 错误码
     - $1: 错误信息
     */
    case commonError(Int, String? = nil)
    
    /**
     服务端内部错误
     
     - Parameters:
     - $0: 错误信息
     */
    case serverInternalError(String? = "服务器忙，请稍后重试")
    
    /**
     用户被踢出，需要做退出登录处理
     
     - Parameters:
     - $0: 错误信息
     */
    case kickout(String? = "你的账号已在其他客户端登陆")
    
    /**
     余额不足，引导用户充值
     
     - Parameters:
     - $0: 错误信息
     */
    case balance(String? = "余额不足")
    
    /**
     庭院未开通
     
     - Parameters:
     - $0: 错误信息
     */
    case gameClose(String? = "请先开通")
    
    /**
     不是VIP，引导用户充值
     */
    case notVIP(String? = "还不是VIP")
    
    /**
     非法请求，一般是参数格式、类型有误
     
     - Parameters:
     - $0: 错误信息
     */
    case illegal(String? = "非法请求")
    
    /**
     相关接口服务端有加锁，操作频率过快，可做重试
     
     - Parameters:
     - $0: 错误信息
     */
    case limitReached(String? = "请求过快")
    
    /**
     本地时间和服务端时间有偏差，可做重试并矫正本地时间
     
     - Parameters:
     - $0: 错误信息
     */
    case timeOffset(serverTime: Int64? = nil, String? = "请求超时或本地时间与服务端时间差距过大")
    
    /**
     未知错误
     */
    case undefined
    
    static let okCode = 200
    static let undefinedCode = Int.min
    
    // 业务基础错误码 (APIResult.code != 200 时)
    static let failedCode = 400 // 错误
    static let shouldReloginCode = 401 // 需要重新登录
    
    // errorCode
    /// 服务器内部错误 (服务器忙)
    static let serverInternalErrorCode = 10001
    /// 其他地方登录，被登出
    static let kickoutCode = 20002
    /// 余额 (金币不足)
    static let balanceCode = 90001
    /// 校准手机时间
    static let timeOffsetCode = 9005
    /// 不是 VIP
    static let notVIPCode = 10017
    
    /// 游戏关闭
    static let gameCloseCode = 5100189
    /// 电量不足
    static let batteryCode = 94002
    
    var isBalanceError: Bool {
        errorCode == Self.balanceCode
    }
    var isBatteryError: Bool {
        errorCode == Self.batteryCode
    }
}

extension APIError {
    
    init?(from: APIResult) {
        guard var code = from.code else { return nil }
        if code != Self.okCode { // != 200 表示后端返回了错误信息
            if code == Self.failedCode { //
                code = from.errorCode ?? 0 // 具体错误信息从 errorCode 取
             } else if code == Self.shouldReloginCode {
                code = from.errorCode ?? 0
                // return nil // 转移到 didEnd中了， 20210127
            }
        }
        self.init(code: code, message: from.message, response: from)
    }
    
    init(from: MoyaError) {
        switch from {
        case let .statusCode(response):
            // 网关层错误
            if let getawayError = GetawayError(rawValue: response.statusCode) {
                self = .getawayError(getawayError)
                return
            }
        case let .underlying(_, response):
            // 网络层错误
            if let response = response {
                // 有响应，应该走到网关层错误去
                self = APIError(from: .statusCode(response))
                return
            }
        default:
            break
        }
        self = .moyaError(from)
    }
    
    init?(code: Int, message: String? = nil, response: APIResult? = nil) {
        // 只返回业务层错误
        switch code {
        case Self.okCode:
            return nil
        case Self.undefinedCode:
            self = .undefined
        case Self.serverInternalErrorCode:
            self = .serverInternalError(message)
        case Self.kickoutCode:
            self = .kickout(message)
        case Self.balanceCode:
            self = .balance(message)
        case Self.notVIPCode:
            self = .notVIP(message)
        case Self.timeOffsetCode:
            self = .timeOffset(serverTime: response?.timestamp, message)
        case Self.gameCloseCode:
            self = .gameClose(message)
        default:
            self = .commonError(code, message)
        }
    }
    
    init?(errorCode: Int) {
        self.init(code: errorCode)
    }
    
    var errorCode: Int {
        switch self {
        case let .moyaError(error):
            return -abs(error.code)
        case .serverInternalError:
            return Self.serverInternalErrorCode
        case .kickout:
            return Self.kickoutCode
        case .balance:
            return Self.balanceCode
        case .notVIP:
            return Self.notVIPCode
        case .timeOffset:
            return Self.timeOffsetCode
        case let .commonError(code, _):
            return code
        case let .getawayError(error):
            return error.rawValue
        default:
            return Self.undefinedCode
        }
    }
    
    /// 错误优先级
    ///
    /// 依次为：网关错误、客户端网络层错误、服务端内部错误、踢出、余额不足、数据映射错误、普通业务报错
    var priority: ErrorPriority {
        switch self {
        case .getawayError:
            return .high(100)
        case .moyaError:
            return .high(90)
        case .serverInternalError:
            return .high(80)
        case .kickout:
            return .high(70)
        case .balance:
            return .high(60)
        case .notVIP:
            return .high(59)
        case .mappingError:
            return .normal(100)
        default:
            return .normal()
        }
    }
    
    var debugDescription: String {
        var errorString: String = "❌ \(priority) \n"
        switch self {
        case let .moyaError(error):
            errorString += "Moya: \(error.errorDescription ?? "unknown error: \(error.errorCode)")"
        case let .mappingError(response):
            errorString += "Mapping failed from \(response)"
        case let .getawayError(error):
            errorString += "Getaway: \(error.debugDescription)"
        case let .serverInternalError(text),
             let .kickout(text),
             let .balance(text),
             let .notVIP(text),
             let .illegal(text),
             let .timeOffset(_, text),
             let .limitReached(text):
            errorString += text ?? "Code \(errorCode) with no further informations"
        case let .commonError(code, text):
            errorString += "Common error (\(code), \(text ?? "no description"))"
        default:
            errorString += "Undefined error"
        }
        return errorString
    }
    
    var description: String {
        var errorString: String = ""
        switch self {
        case let .moyaError(error):
            errorString += "\(error.errorDescription ?? "未知错误: \(error.errorCode)")"
        case .mappingError:
            errorString += "服务器开小差了，请稍后重试"
        case let .getawayError(error):
            errorString += error.localizedDescription
        case let .serverInternalError(text),
             let .kickout(text),
             let .balance(text),
             let .notVIP(text),
             let .illegal(text),
             let .timeOffset(_, text),
             let .limitReached(text):
            errorString += text ?? "未知错误：\(errorCode)"
        case let .commonError(code, text):
            errorString += text ?? "未知错误：\(code)"
        default:
            errorString += "未知错误"
        }
        return errorString.replacingOccurrences(of: "盘币", with: Const.coinUnit)
    }
    
    /// 在调用层声明操作出错时需要重试时，
    /// 判断是否可以重试
    ///
    /// 网关超时、404、操作过快、时间偏差、服务端内部错误和部分客户端网络层错误允许重试
    var shouldRetry: Bool {
        switch self {
        case let .getawayError(getawayError):
            // 网关层错误
            switch getawayError {
            case .getawayTimeout, .getawayNotFound:
                // 网关超时、404重试
                return true
            default:
                return false
            }
        case let .moyaError(moyaError):
            // Moya 错误
            switch moyaError {
            case let .statusCode(response):
                // 网关层错误
                if let getawayError = GetawayError(rawValue: response.statusCode) {
                    return APIError.getawayError(getawayError).shouldRetry
                }
                return false
            case let .underlying(error, response):
                // 网络层错误
                if let response = response {
                    // 有响应，应该走到网关层错误去
                    return APIError.moyaError(.statusCode(response)).shouldRetry
                }
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain {
                    let code = Int32(nsError.code)
                    switch code {
                    // 不应该重试的网络层错误
                    case CFNetworkErrors.cfHostErrorHostNotFound.rawValue,
                    CFNetworkErrors.cfHostErrorUnknown.rawValue, // Query the kCFGetAddrInfoFailureKey to get the value returned fromCFNetworkErrors. getaddrinfo; lookup in netdb.h
                    CFNetworkErrors.cfErrorHTTPAuthenticationTypeUnsupported.rawValue,
                    CFNetworkErrors.cfErrorHTTPBadCredentials.rawValue,
                    CFNetworkErrors.cfErrorHTTPParseFailure.rawValue,
                    CFNetworkErrors.cfErrorHTTPRedirectionLoopDetected.rawValue,
                    CFNetworkErrors.cfErrorHTTPBadURL.rawValue,
                    CFNetworkErrors.cfErrorHTTPBadProxyCredentials.rawValue,
                    CFNetworkErrors.cfErrorPACFileError.rawValue,
                    CFNetworkErrors.cfErrorPACFileAuth.rawValue,
                    CFNetworkErrors.cfStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod.rawValue,
                    CFNetworkErrors.cfurlErrorUnknown.rawValue,
                    CFNetworkErrors.cfurlErrorCancelled.rawValue,
                    CFNetworkErrors.cfurlErrorBadURL.rawValue,
                    CFNetworkErrors.cfurlErrorUnsupportedURL.rawValue,
                    CFNetworkErrors.cfurlErrorHTTPTooManyRedirects.rawValue,
                    CFNetworkErrors.cfurlErrorBadServerResponse.rawValue,
                    CFNetworkErrors.cfurlErrorUserCancelledAuthentication.rawValue,
                    CFNetworkErrors.cfurlErrorUserAuthenticationRequired.rawValue,
                    CFNetworkErrors.cfurlErrorZeroByteResource.rawValue,
                    CFNetworkErrors.cfurlErrorCannotDecodeRawData.rawValue,
                    CFNetworkErrors.cfurlErrorCannotDecodeContentData.rawValue,
                    CFNetworkErrors.cfurlErrorCannotParseResponse.rawValue,
                    CFNetworkErrors.cfurlErrorInternationalRoamingOff.rawValue,
                    CFNetworkErrors.cfurlErrorCallIsActive.rawValue,
                    CFNetworkErrors.cfurlErrorDataNotAllowed.rawValue,
                    CFNetworkErrors.cfurlErrorRequestBodyStreamExhausted.rawValue,
                    CFNetworkErrors.cfurlErrorFileDoesNotExist.rawValue,
                    CFNetworkErrors.cfurlErrorFileIsDirectory.rawValue,
                    CFNetworkErrors.cfurlErrorNoPermissionsToReadFile.rawValue,
                    CFNetworkErrors.cfurlErrorDataLengthExceedsMaximum.rawValue,
                    CFNetworkErrors.cfurlErrorServerCertificateHasBadDate.rawValue,
                    CFNetworkErrors.cfurlErrorServerCertificateUntrusted.rawValue,
                    CFNetworkErrors.cfurlErrorServerCertificateHasUnknownRoot.rawValue,
                    CFNetworkErrors.cfurlErrorServerCertificateNotYetValid.rawValue,
                    CFNetworkErrors.cfurlErrorClientCertificateRejected.rawValue,
                    CFNetworkErrors.cfurlErrorClientCertificateRequired.rawValue,
                    CFNetworkErrors.cfurlErrorCannotLoadFromNetwork.rawValue,
                    CFNetworkErrors.cfhttpCookieCannotParseCookieFile.rawValue,
                    CFNetworkErrors.cfNetServiceErrorUnknown.rawValue,
                    CFNetworkErrors.cfNetServiceErrorCollision.rawValue,
                    CFNetworkErrors.cfNetServiceErrorNotFound.rawValue,
                    CFNetworkErrors.cfNetServiceErrorInProgress.rawValue,
                    CFNetworkErrors.cfNetServiceErrorBadArgument.rawValue,
                    CFNetworkErrors.cfNetServiceErrorCancel.rawValue,
                    CFNetworkErrors.cfNetServiceErrorInvalid.rawValue,
                    101, // null address
                    102: // Ignore "Frame Load Interrupted" errors. Seen after app store links.
                        return false
                    default:
                        return true
                    }
                }
                return false
            default:
                return false
            }
        case .serverInternalError, .timeOffset, .limitReached:
            // 部分业务基础错误重试
            return true
        default:
            return false
        }
    }
    
    typealias RetryTestClosure = (Error) -> Bool
    
    /**
     当请求发生错误时，且请求行为中包含重试时，
     用于判断产生的 error 是否需要重试，
     当 error 遵循 `RetryTestable` 协议时，
     使用其 `shouldRetry` 判断是否需要重试，
     可参考 `APIError` 的 `shouldRetry`
     
     - Parameters:
     - customTest: 业务层的额外判断
     - Returns:
     - `RetryTestClosure`，使用参见 `APIRequestBehavior` 的 `.retry`
     */
    static func retryTest(and customTest: RetryTestClosure? = nil) -> RetryTestClosure {
        { (error) -> Bool in
            llog("Error occurred: \n\(error)")
            if let customTest = customTest, customTest(error) {
                return true
            }
            if let apiError = error as? RetryTestable, apiError.shouldRetry {
                return true
            }
            return false
        }
    }
    
}
