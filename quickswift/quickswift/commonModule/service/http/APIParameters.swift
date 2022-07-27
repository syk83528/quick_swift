//
// Created by Wildog on 12/2/19.
// Copyright (c) 2019 Wildog. All rights reserved.
//

import UIKit
import common
import Alamofire
import Moya
import HandyJSON

extension Dict: HandyJSON, _ExtendCustomModelType {
    
}

/// `APIParameters` has parameter encoding and values. Use `=>` operator for syntactic sugar.
///
/// Example:
///
/// ```
/// JSONEncoding() => [
///   "key1": "value1",
///   "key2": "value2",
///   "key3": nil,      // will be ignored
/// ]
/// ```
/// Or just:
/// ```
/// [
///     "key1": "value1",
///     "key2": "value2"
/// ]
/// ```
/// for default encoding
struct APIParameters {
    public var encoding: Alamofire.ParameterEncoding
    public var values: [String: Any]

    public init(encoding: Alamofire.ParameterEncoding = APIParamEncoding.default, values: [String: Any?]?) {
        self.encoding = encoding
        if values == nil {
            self.values = [:]
            return
        }
        self.values = values?.filterNil().toJSON() ?? [:]
    }
}

extension APIParameters: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any?)...) {
        var values: [String: Any?] = [:]
        for (key, value) in elements {
            values[key] = value
        }
        self.init(encoding: APIParamEncoding.default, values: values)
    }
}

infix operator =>

func => (encoding: Alamofire.ParameterEncoding, values: [String: Any?]) -> APIParameters {
    APIParameters(encoding: encoding, values: values)
}

/// API 请求参数编码
///
/// 默认实现对 GET 请求使用 `URLEncoding` 编码，
/// 对其他请求使用 `JSONEncoding` 编码
struct APIParamEncoding: ParameterEncoding {

    static var `default`: APIParamEncoding { APIParamEncoding() }

    static let APIHashKey = "hash"

    func encode(_ urlRequest: Alamofire.URLRequestConvertible, with parameters: Alamofire.Parameters?) throws -> URLRequest {
        if let httpMethod = urlRequest.urlRequest?.httpMethod, HTTPMethod.get.rawValue == httpMethod {
            return try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        var request = try JSONEncoding.default.encode(urlRequest, with: parameters)
        if let body = request.httpBody {
            var hasher = Hasher()
            hasher.combine(body)
            request.addValue(String(hasher.finalize()), forHTTPHeaderField: APIParamEncoding.APIHashKey)
        }
        return request
    }
}

extension URLRequest {

    var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        if let hash = value(forHTTPHeaderField: APIParamEncoding.APIHashKey) {
            hasher.combine(hash)
        }
        return hasher.finalize()
    }
}
