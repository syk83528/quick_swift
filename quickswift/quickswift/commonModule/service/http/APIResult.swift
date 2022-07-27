//
//  APIResult.swift
//  spsd
//
//  Created by Wildog on 12/4/19.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import common
import HandyJSON
import ReactiveCocoa
import ReactiveSwift
import Moya
import SwiftyJSON

/// 解析后的 API 请求响应 //暂更名为APIResult 原名APIResponse被腾讯SDK占用了
struct APIResult: Decodable {
    
    /// 业务状态码
    let code: Int?
    
    /// 错误状态吗
    let errorCode: Int?
    
    /// 服务端时间
    let timestamp: Int64?
    
    /// 错误消息
    let message: String?
    
    /// 业务数据
    var result: JSON?

    /// 通用业务数据，包含用户余额等
    var ext: JSON?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case errorCode = "errorCode"
        case timestamp = "timestamp"
        case message = "errorMsg"
        case result = "result"
        case ext = "ext"
    }
    
    enum ObjectType: Int {
        case result, ext
        
        func object(from: APIResult) -> JSON? {
            switch self {
            case .result:
                return from.result
            case .ext:
                return from.ext
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        timestamp = try values.decodeIfPresent(Int64.self, forKey: .timestamp)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        result = try values.decodeIfPresent(JSON.self, forKey: .result)
        ext = try values.decodeIfPresent(JSON.self, forKey: .ext)
        errorCode = try values.decodeIfPresent(Int.self, forKey: .errorCode)
    }
    
}

extension APIResult {
    /// keyPath 为 result 给 nil
    func unwrap<T: HandyJSON>(list: T.Type, atKeyPath keyPath: String? = nil, object: APIResult.ObjectType = .result) -> [T]? {
        try? map(list, object: object, listKey: keyPath)
    }
    /// keyPath 为 result 给 nil
    func unwrap<T: HandyJSON>(_ type: T.Type, atKeyPath keyPath: String? = nil, object: APIResult.ObjectType = .result) -> T? {
        try? map(type, object: object, atKeyPath: keyPath)
    }
    
}

private extension APIResult {
    func filter<R: RangeExpression>(codes: R) throws -> APIResult where R.Bound == Int {
        guard codes.contains(code ?? 0) else {
            throw APIError(from: self) ?? APIError.undefined
        }
        return self
    }
    
    func filter(code: Int) throws -> APIResult {
        try filter(codes: code...code)
    }
    
    func map(_ type: JSON.Type, object: ObjectType = .result, atKeyPath keyPath: String? = nil) throws -> JSON? {
        let result = object.object(from: self)
        if let keyPath = keyPath {
            let path: [JSONSubscriptType] = keyPath.components(separatedBy: ".")
            if let value = result?[path] {
                return value
            } else {
                return nil
            }
        }
        return result
    }
    
    func map(_ type: JSON.Type, object: ObjectType = .result, listKey: String? = "list") throws -> [JSON]? {
        let result = object.object(from: self)
        if let listKey = listKey, result != nil {
            let path: [JSONSubscriptType] = listKey.components(separatedBy: ".")
            if let value = result?[path] {
                if let r = value.array {
                    return r
                } else {
                    throw APIError.mappingError(self)
                }
            } else {
                return nil
            }
        }
        if let r = result?.array {
            return r
        } else {
            throw APIError.mappingError(self)
        }
    }
    
    func map<T>(_ type: T.Type, object: ObjectType = .result, atKeyPath keyPath: String? = nil) throws -> T? where T: HandyJSON {
        let result = object.object(from: self)
        var raw: Dict? = result?.dictionaryObject
        if let keyPath = keyPath {
            let path: [JSONSubscriptType] = keyPath.components(separatedBy: ".")
            if let value = result?[path] {
                if let sameType = value.object as? T {
                    return sameType
                }
                if let r = value.dictionaryObject {
                    raw = r
                } else {
                    throw APIError.mappingError(self)
                }
            } else {
                return nil
            }
        }
        return T.deserialize(from: raw)
    }
    
    func map<T>(_ type: T.Type, object: ObjectType = .result, listKey: String? = "list") throws -> [T]? where T: HandyJSON {
        if let list = try self.map(JSON.self, object: object, listKey: listKey) {
            return list.compactMap {
                if let sameType = $0.object as? T {
                    return sameType
                }
                return T.deserialize(from: $0.dictionaryObject )
            }
        }
        return nil
    }
    
    func map<T>(_ type: T.Type, object: ObjectType = .result, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder()) throws -> T? where T: Decodable {
        let result = object.object(from: self)
        var json: JSON?
        if let keyPath = keyPath {
            let path: [JSONSubscriptType] = keyPath.components(separatedBy: ".")
            if let value = result?[path] {
                json = value
            } else {
                return nil
            }
        } else {
            json = result
        }
        guard let jsonObject = json?.object else {
            return nil
        }
        guard let decoded = jsonObject as? T else {
            guard let data = try? json?.rawData() else {
                throw APIError.mappingError(self)
            }
            guard let decodedObject = try? decoder.decode(T.self, from: data) else {
                throw APIError.mappingError(self)
            }
            return decodedObject
        }
        return decoded
    }
    
    func map<T>(_ type: T.Type, object: ObjectType = .result, listKey: String? = "list", decoder: JSONDecoder = JSONDecoder()) throws -> [T]? where T: Decodable {
        if let list = try self.map(JSON.self, object: object, listKey: listKey) {
            return list.compactMap { json in
                if let jsonObject = json.object as? T {
                    return jsonObject
                }
                guard let data = try? json.rawData() else {
                    return nil
                }
                guard let decodedObject = try? decoder.decode(T.self, from: data) else {
                    return nil
                }
                return decodedObject
            }
        }
        return nil
    }
}

/** 常用的 API 请求的 SignalProducer 的转换和处理
 
 按用途主要分三类：
 - 过滤状态码
 - 解析原始数据为 Decodable / JSON / HandyJSON 类型的模型 或 模型的数组
 - 添加副作用，拆分数据处理逻辑，对数据各个结构解析成不同类型做不同处理
 */
extension SignalProducerProtocol where Value == APIResult {
    
    /**
     将指定范围内的业务状态码标记为错误
     
     - Parameters:
        - codes: 状态码范围
     
     - Returns:
        转换后的 `SignalProducer`，指定范围内的状态码会被解析成错误发送
     */
    func filter<R: RangeExpression>(codes: R) -> SignalProducer<Value, Error> where R.Bound == Int {
        producer.flatMap(.latest) { response in
            Self.unwrapThrowable { try response.filter(codes: codes) }
        }
    }

    /**
     将指定的业务状态码标记为错误
     
     - Parameters:
        - code: 状态码
     
     - Returns:
     转换后的 `SignalProducer`，指定的状态码会被解析成错误发送
     */
    func filter(code: Int) -> SignalProducer<Value, Error> {
        producer.flatMap(.latest) { response in
            Self.unwrapThrowable { try response.filter(code: code) }
        }
    }
    
    /**
     将 `APIResult` 内的业务数据转换成 JSON 模型
     
     - Parameters:
        - type: 模型类型
        - object: 要转换的业务数据，默认为 .result
        - keyPath: 要转换的数据的 keyPath，默认为 nil 取一级数据
     
     - Returns:
     转换后的 `SignalProducer`，值为模型类型的 **Optional**
     */
    func map(_ type: JSON.Type, object: APIResult.ObjectType = .result, atKeyPath keyPath: String? = nil) -> SignalProducer<JSON?, Error> {
        producer.flatMap(.latest) { response in
            Self.unwrapThrowable { try response.map(type, object: object, atKeyPath: keyPath) }
        }
    }
    
    /**
     将 APIResult 内的业务数据转换成 JSON 模型数组
     
     - Parameters:
        - type: 模型类型
        - object: 要转换的业务数据，默认为 .result
        - listKey: 要转换的原始数据的数组在数据内的 key，默认为 "list"
     
     - Returns:
     转换后的 `SignalProducer`，值为元素类型为模型类型的 **Optional** 的数组
     */
    func map(list type: JSON.Type, object: APIResult.ObjectType = .result, listKey: String? = "list") -> SignalProducer<[JSON]?, Error> {
        producer.flatMap(.latest) { response in
            Self.unwrapThrowable { try response.map(type, object: object, listKey: listKey) }
        }
    }
    
    /**
     将 `APIResult` 内的业务数据转换成 HandyJSON 模型
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - keyPath: 要转换的数据的 keyPath，默认为 nil 取一级数据
     
     - Returns:
     转换后的 `SignalProducer`，值为模型类型的 **Optional**
     */
    func map<T>(_ type: T.Type, object: APIResult.ObjectType = .result, atKeyPath keyPath: String? = nil) -> SignalProducer<T?, Error> where T: HandyJSON {
        producer.flatMap(.latest) { response in
            Self.unwrapThrowable { try response.map(type, object: object, atKeyPath: keyPath) }
        }
    }

    /**
     将 APIResult 内的业务数据转换成 HandyJSON 模型数组
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - listKey: 要转换的原始数据的数组在数据内的 key，默认为 "list"
     
     - Returns:
     转换后的 `SignalProducer`，值为元素类型为模型类型的 **Optional** 的数组
     */
    func map<T>(list type: T.Type, object: APIResult.ObjectType = .result, listKey keyPath: String? = "list") -> SignalProducer<[T]?, Error> where T: HandyJSON {
        producer.flatMap(.latest) { response in
            Self.unwrapThrowable { try response.map(type, object: object, listKey: keyPath) }
        }
    }
    
    /**
     将 `APIResult` 内的业务数据转换成 Decodable 模型或原始类型(String、Int等)
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - keyPath: 要转换的数据的 keyPath，默认为 nil 取一级数据
         - decoder: 解码器，默认为 JSONDecoder
     
     - Returns:
     转换后的 `SignalProducer`，值为模型类型的 **Optional**
     
     很适合只取响应数据中某个特定字段的场景
     */
    func map<T>(_ type: T.Type, object: APIResult.ObjectType = .result, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<T?, Error> where T: Decodable {
        producer.flatMap(.latest) { response in
            Self.unwrapThrowable { try response.map(type, object: object, atKeyPath: keyPath, decoder: decoder) }
        }
    }

    /**
     将 APIResult 内的业务数据转换成 Decodable 或原始类型模型的数组
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - listKey: 要转换的原始数据的数组在数据内的 key，默认为 "list"
         - decoder: 解码器，默认为 JSONDecoder
     
     - Returns:
     转换后的 `SignalProducer`，值为元素类型为模型类型的 **Optional** 的数组
     */
    func map<T>(list type: T.Type, object: APIResult.ObjectType = .result, listKey keyPath: String? = "list", decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<[T]?, Error> where T: Decodable {
        producer.flatMap(.latest) { response in
            Self.unwrapThrowable { try response.map(type, object: object, listKey: keyPath, decoder: decoder) }
        }
    }

    /**
     将 `APIResult` 内的业务数据转换成 JSON 模型
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - keyPath: 要转换的数据的 keyPath，默认为 nil 取一级数据
     
     - Returns:
     转换后的 `SignalProducer`，值为模型类型
     */
    func unwrap(_ type: JSON.Type, object: APIResult.ObjectType = .result, atKeyPath keyPath: String? = nil) -> SignalProducer<JSON, Error> {
        map(type, object: object, atKeyPath: keyPath).skipNil()
    }

    /**
     将 APIResult 内的业务数据转换成 JSON 模型数组
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - listKey: 要转换的原始数据的数组在数据内的 key，默认为 "list"
     
     - Returns:
     转换后的 `SignalProducer`，值为元素类型为模型类型的数组
     */
    func unwrap(list type: JSON.Type, object: APIResult.ObjectType = .result, listKey: String? = "list") -> SignalProducer<[JSON], Error> {
        map(list: type, object: object, listKey: listKey).skipNil()
    }

    /**
     将 `APIResult` 内的业务数据转换成 HandyJSON 模型
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - keyPath: 要转换的数据的 keyPath，默认为 nil 取一级数据
     
     - Returns:
     转换后的 `SignalProducer`，值为模型类型
     */
    func unwrap<T>(_ type: T.Type, object: APIResult.ObjectType = .result, atKeyPath keyPath: String? = nil) -> SignalProducer<T, Error> where T: HandyJSON {
        map(type, object: object, atKeyPath: keyPath).skipNil()
    }

    /**
     将 APIResult 内的业务数据转换成 HandyJSON 模型数组
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - listKey: 要转换的原始数据的数组在数据内的 key，默认为 "list"
     
     - Returns:
     转换后的 `SignalProducer`，值为元素类型为模型类型的数组
     */
    func unwrap<T>(list type: T.Type, object: APIResult.ObjectType = .result, listKey keyPath: String? = "list") -> SignalProducer<[T], Error> where T: HandyJSON {
        map(list: type, object: object, listKey: keyPath).skipNil()
    }
    
    /**
     将 `APIResult` 内的业务数据转换成 Decodable 模型或原始类型(String、Int等)
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - keyPath: 要转换的数据的 keyPath，默认为 nil 取一级数据
         - decoder: 解码器，默认为 JSONDecoder
     
     - Returns:
     转换后的 `SignalProducer`，值为模型类型
     
     很适合只取响应数据中某个特定字段的场景
     */
    func unwrap<T>(_ type: T.Type, object: APIResult.ObjectType = .result, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<T, Error> where T: Decodable {
        map(type, object: object, atKeyPath: keyPath, decoder: decoder).skipNil()
    }

    /**
     将 APIResult 内的业务数据转换成 Decodable 或原始类型模型的数组
     
     - Parameters:
         - type: 模型类型
         - object: 要转换的业务数据，默认为 .result
         - listKey: 要转换的原始数据的数组在数据内的 key，默认为 "list"
         - decoder: 解码器，默认为 JSONDecoder
     
     - Returns:
     转换后的 `SignalProducer`，值为元素类型为模型类型的数组
     */
    func unwrap<T>(list type: T.Type, object: APIResult.ObjectType = .result, listKey keyPath: String? = "list", decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<[T], Error> where T: Decodable {
        map(list: type, object: object, listKey: keyPath, decoder: decoder).skipNil()
    }

    /**
     为请求的 SignalProducer 添加副作用，
     将 `APIResult` 内的业务数据转换成 HandyJSON 模型并处理
     
     - Parameters:
         - closure: 副作用 closure，T 声明需要解析出的模型类型
         - object: 要转换的业务数据，默认为 .result
         - keypath: 要转换的数据的 keyPath，默认为 nil 取一级数据
     
     - Returns:
     添加副作用后的 `SignalProducer`
     
     适合针对单个请求的复杂处理流程拆分成多个副作用
     */
    func `do`<T>(_ closure: @escaping (T) -> Void, object: APIResult.ObjectType = .result, atKeyPath keypath: String? = nil) -> SignalProducer<Value, Error> where T: HandyJSON {
        producer.on(value: { (response) in
            do {
                if let value = try response.map(T.self, object: object, atKeyPath: keypath) {
                    closure(value)
                }
            } catch {}
        })
    }

    /**
     为请求的 SignalProducer 添加副作用，
     将 `APIResult` 内的业务数据转换成 HandyJSON 模型数组并处理
     
     - Parameters:
         - closure: 副作用 closure，T 声明需要解析出的模型类型
         - object: 要转换的业务数据，默认为 .result
         - keypath: 要转换的数据的 keyPath，默认为 nil 取一级数据
     
     - Returns:
     添加副作用后的 `SignalProducer`
     
     适合针对单个请求的复杂处理流程拆分成多个副作用
     */
    func `do`<T>(_ closure: @escaping ([T]) -> Void, object: APIResult.ObjectType = .result, listKey keypath: String? = nil) -> SignalProducer<Value, Error> where T: HandyJSON {
        producer.on(value: { (response) in
            do {
                if let value = try response.map(T.self, object: object, listKey: keypath) {
                    closure(value)
                }
            } catch {}
        })
    }
    
    /**
     为请求的 SignalProducer 添加副作用，
     将 `APIResult` 内的业务数据转换成 Decodable 或原始类型模型并处理
     
     - Parameters:
         - closure: 副作用 closure，T 声明需要解析出的模型类型
         - object: 要转换的业务数据，默认为 .result
         - keypath: 要转换的数据的 keyPath，默认为 nil 取一级数据
         - decoder: 解码器，默认为 JSONDecoder

     - Returns:
     添加副作用后的 `SignalProducer`
     
     适合针对单个请求的复杂处理流程拆分成多个副作用
     */
    func `do`<T>(_ closure: @escaping (T) -> Void, object: APIResult.ObjectType = .result, atKeyPath keypath: String? = nil, decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<Value, Error> where T: Decodable {
        producer.on(value: { (response) in
            do {
                if let value = try response.map(T.self, object: object, atKeyPath: keypath, decoder: decoder) {
                    closure(value)
                }
            } catch {}
        })
    }
    
    /**
     为请求的 SignalProducer 添加副作用，
     将 `APIResult` 内的业务数据转换成 Decodable 或原始类型模型的数组并处理
     
     - Parameters:
         - closure: 副作用 closure，T 声明需要解析出的模型类型
         - object: 要转换的业务数据，默认为 .result
         - listKey: 要转换的原始数据的数组在数据内的 key，默认为 "list"
         - decoder: 解码器，默认为 JSONDecoder
     
     - Returns:
     添加副作用后的 `SignalProducer`
     
     适合针对单个请求的复杂处理流程拆分成多个副作用
     */
    func `do`<T>(_ closure: @escaping ([T]) -> Void, object: APIResult.ObjectType = .result, listKey keypath: String? = nil, decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<Value, Error> where T: Decodable {
        producer.on(value: { (response) in
            do {
                if let value = try response.map(T.self, object: object, listKey: keypath, decoder: decoder) {
                    closure(value)
                }
            } catch {}
        })
    }

    private static func unwrapThrowable<T>(throwable: () throws -> T) -> SignalProducer<T, Error> {
        do {
            return SignalProducer(value: try throwable())
        } catch {
            if let error = error as? Error {
                return SignalProducer(error: error)
            } else {
                // The cast above should never fail, but just in case.
                return SignalProducer.never
            }
        }
    }
}

fileprivate extension JSON {
    
    func map(_ type: JSON.Type, atKeyPath keyPath: String? = nil) throws -> JSON? {
        if let keyPath = keyPath {
            let path: [JSONSubscriptType] = keyPath.components(separatedBy: ".")
            let value = self[path]
            if value != .null {
                return value
            } else {
                return nil
            }
        }
        return nil
    }
    
    func map(_ type: JSON.Type, listKey: String? = "list") throws -> [JSON]? {
        if let listKey = listKey {
            let path: [JSONSubscriptType] = listKey.components(separatedBy: ".")
            let value = self[path]
            if value != .null {
                if let r = value.array {
                    return r
                } else {
                    throw SwiftyJSONError.wrongType
                }
            } else {
                return nil
            }
        }
        if let r = self.array {
            return r
        } else {
            throw SwiftyJSONError.wrongType
        }
    }
    
    func map<T>(_ type: T.Type, atKeyPath keyPath: String? = nil) throws -> T? where T: HandyJSON {
        var raw: Dict? = self.dictionaryObject
        if let keyPath = keyPath {
            let path: [JSONSubscriptType] = keyPath.components(separatedBy: ".")
            let value = self[path]
            if value != .null {
                if let r = value.dictionaryObject {
                    raw = r
                } else {
                    throw SwiftyJSONError.wrongType
                }
            } else {
                return nil
            }
        }
        return T.deserialize(from: raw)
    }
    
    func map<T>(_ type: T.Type, listKey: String? = "list") throws -> [T]? where T: HandyJSON {
        if let list = try self.map(JSON.self, listKey: listKey) {
            return list.compactMap { T.deserialize(from: $0.dictionaryObject ) }
        }
        return nil
    }
    
    func map<T>(_ type: T.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder()) throws -> T? where T: Decodable {
        var json: JSON?
        if let keyPath = keyPath {
            let path: [JSONSubscriptType] = keyPath.components(separatedBy: ".")
            let value = self[path]
            if value != .null {
                json = value
            } else {
                return nil
            }
        } else {
            json = self
        }
        guard let jsonObject = json?.object else {
            return nil
        }
        guard let decoded = jsonObject as? T else {
            guard let data = try? json?.rawData() else {
                throw SwiftyJSONError.notExist
            }
            guard let decodedObject = try? decoder.decode(T.self, from: data) else {
                throw SwiftyJSONError.invalidJSON
            }
            return decodedObject
        }
        return decoded
    }
    
    func map<T>(_ type: T.Type, listKey: String? = "list", decoder: JSONDecoder = JSONDecoder()) throws -> [T]? where T: Decodable {
        if let list = try self.map(JSON.self, listKey: listKey) {
            return list.compactMap { json in
                if let jsonObject = json.object as? T {
                    return jsonObject
                }
                guard let data = try? json.rawData() else {
                    return nil
                }
                guard let decodedObject = try? decoder.decode(T.self, from: data) else {
                    return nil
                }
                return decodedObject
            }
        }
        return nil
    }
}

//extension SignalProducerProtocol where Value == JSON, Error == IMError {
//
//    func map(_ type: JSON.Type, atKeyPath keyPath: String? = nil) -> SignalProducer<JSON?, Error> {
//        producer.flatMap(.latest) { response in
//            Self.unwrapThrowable { try response.map(type, atKeyPath: keyPath) }
//        }
//    }
//
//    func map(list type: JSON.Type, listKey: String? = "list") -> SignalProducer<[JSON]?, Error> {
//        producer.flatMap(.latest) { response in
//            Self.unwrapThrowable { try response.map(type, listKey: listKey) }
//        }
//    }
//
//    func map<T>(_ type: T.Type, atKeyPath keyPath: String? = nil) -> SignalProducer<T?, Error> where T: HandyJSON {
//        producer.flatMap(.latest) { response in
//            Self.unwrapThrowable { try response.map(type, atKeyPath: keyPath) }
//        }
//    }
//
//    func map<T>(list type: T.Type, listKey keyPath: String? = "list") -> SignalProducer<[T]?, Error> where T: HandyJSON {
//        producer.flatMap(.latest) { response in
//            Self.unwrapThrowable { try response.map(type, listKey: keyPath) }
//        }
//    }
//
//    func map<T>(_ type: T.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<T?, Error> where T: Decodable {
//        producer.flatMap(.latest) { response in
//            Self.unwrapThrowable { try response.map(type, atKeyPath: keyPath, decoder: decoder) }
//        }
//    }
//
//    func map<T>(list type: T.Type, listKey keyPath: String? = "list", decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<[T]?, Error> where T: Decodable {
//        producer.flatMap(.latest) { response in
//            Self.unwrapThrowable { try response.map(type, listKey: keyPath, decoder: decoder) }
//        }
//    }
//
//    func unwrap(_ type: JSON.Type, atKeyPath keyPath: String? = nil) -> SignalProducer<JSON, Error> {
//        map(type, atKeyPath: keyPath).skipNil()
//    }
//
//    func unwrap(list type: JSON.Type, listKey: String? = "list") -> SignalProducer<[JSON], Error> {
//        map(list: type, listKey: listKey).skipNil()
//    }
//
//    func unwrap<T>(_ type: T.Type, atKeyPath keyPath: String? = nil) -> SignalProducer<T, Error> where T: HandyJSON {
//        map(type, atKeyPath: keyPath).skipNil()
//    }
//
//    func unwrap<T>(list type: T.Type, listKey keyPath: String? = "list") -> SignalProducer<[T], Error> where T: HandyJSON {
//        map(list: type, listKey: keyPath).skipNil()
//    }
//
//    func unwrap<T>(_ type: T.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<T, Error> where T: Decodable {
//        map(type, atKeyPath: keyPath, decoder: decoder).skipNil()
//    }
//
//    func unwrap<T>(list type: T.Type, listKey keyPath: String? = "list", decoder: JSONDecoder = JSONDecoder()) -> SignalProducer<[T], Error> where T: Decodable {
//        map(list: type, listKey: keyPath, decoder: decoder).skipNil()
//    }
//
//    func `do`<T>(_ closure: @escaping (T) -> Void, atKeyPath keypath: String? = nil) -> SignalProducer<Value, Error> where T: HandyJSON {
//        producer.on(value: { (response) in
//            do {
//                if let value = try response.map(T.self, atKeyPath: keypath) {
//                    closure(value)
//                }
//            } catch {}
//        })
//    }
//
//    func `do`<T>(_ closure: @escaping ([T]) -> Void, listKey keypath: String? = nil) -> SignalProducer<Value, Error> where T: HandyJSON {
//        producer.on(value: { (response) in
//            do {
//                if let value = try response.map(T.self, listKey: keypath) {
//                    closure(value)
//                }
//            } catch {}
//        })
//    }
//
//    private static func unwrapThrowable<T>(throwable: () throws -> T) -> SignalProducer<T, Error> {
//        do {
//            return SignalProducer(value: try throwable())
//        } catch {
//            if let error = error as? Error {
//                return SignalProducer(error: error)
//            } else {
//                // The cast above should never fail, but just in case.
//                return SignalProducer.never
//            }
//        }
//    }
//
//}
