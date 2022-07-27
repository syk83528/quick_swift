////
////  reactive+http.swift
////  common
////
////  Created by suyikun on 2022/7/27.
////
//
//import Foundation
//
//extension SignalProducerProtocol where Error: RawRepresentable {
//    // 和上面类似，适用范围更广
//    // 原始错误类型为 RawRepresentable，指定错误类型同为 RawRepresentable 且 RawValue 类型相同
//    func filterMapError<T>(type: T.Type) -> SignalProducer<Value, T> where T: RawRepresentable, T.RawValue == Error.RawValue {
//        producer.flatMapError { (error: Error) -> SignalProducer<Value, T> in
//            if let transformedError = T.init(rawValue: error.rawValue) {
//                return SignalProducer<Value, T>(error: transformedError)
//            }
//            return SignalProducer<Value, T>.empty
//        }
//    }
//
//    // 原始错误类型为 RawRepresentable，RawValue 类型为 Int （常见Enum: Int）
//    // 指定错误类型遵循 ErrorCodeConvertible （常见带 associated value 的 Enum）
//    func filterMapError<T>(type: T.Type) -> SignalProducer<Value, T> where T: ErrorCodeConvertible, Error.RawValue == Int {
//        producer.flatMapError { (error: Error) -> SignalProducer<Value, T> in
//            if let transformedError = T.init(errorCode: error.rawValue) {
//                return SignalProducer<Value, T>(error: transformedError)
//            }
//            return SignalProducer<Value, T>.empty
//        }
//    }
//
//    func `catch`<T>(error: @escaping (T) -> Void) -> SignalProducer<Value, Error> where T: RawRepresentable, T.RawValue == Error.RawValue {
//        producer.on(failed: { e in
//            guard let transformedError = T.init(rawValue: e.rawValue) else {
//                return
//            }
//            error(transformedError)
//        })
//    }
//
//    func `catch`<T>(error: @escaping (T) -> Void) -> SignalProducer<Value, Error> where T: ErrorCodeConvertible, Error.RawValue == Int {
//        producer.on(failed: { e in
//            guard let transformedError = T.init(errorCode: e.rawValue) else {
//                return
//            }
//            error(transformedError)
//        })
//    }
//}
//
//extension SignalProducerProtocol {
//    // 忽略指定类型以外的所有错误
//    // 如错误无法被转换为指定类型的错误，将不会发送任何错误
//    // 只适用于原始错误类型和指定类型 bicast 或者原始错误类型遵循 ErrorCodeConvertible 协议时
//    // 常见场景：每个业务定义自己的错误码(Enum: Int)，将 APIError 过滤为特定错误后处理
//    func filterMapError<T>(type: T.Type) -> SignalProducer<Value, T> where T: RawRepresentable, T.RawValue == Int {
//        producer.flatMapError { (error: Error) -> SignalProducer<Value, T> in
//            var transformedError: T?
//            if let concreteError = error as? T {
//                transformedError = T.init(rawValue: concreteError.rawValue)
//            } else if let concreteError = error as? ErrorCodeConvertible {
//                transformedError = T.init(rawValue: concreteError.errorCode)
//            }
//            if let finalError = transformedError {
//                return SignalProducer<Value, T>(error: finalError)
//            }
//            return SignalProducer<Value, T>.empty
//        }
//    }
//
//    func filterMapError<T>(type: T.Type) -> SignalProducer<Value, T> where T: ErrorCodeConvertible {
//        producer.flatMapError { (error: Error) -> SignalProducer<Value, T> in
//            var transformedError: T?
//            if let concreteError = error as? ErrorCodeConvertible {
//                transformedError = T.init(errorCode: concreteError.errorCode)
//            }
//            if let finalError = transformedError {
//                return SignalProducer<Value, T>(error: finalError)
//            }
//            return SignalProducer<Value, T>.empty
//        }
//    }
//
//    func `catch`<T>(error: @escaping (T) -> Void) -> SignalProducer<Value, Error> where T: RawRepresentable, T.RawValue == Int {
//        producer.on(failed: { (e: Error) in
//            var transformedError: T?
//            if let concreteError = e as? T {
//                transformedError = T.init(rawValue: concreteError.rawValue)
//            } else if let concreteError = e as? ErrorCodeConvertible {
//                transformedError = T.init(rawValue: concreteError.errorCode)
//            }
//            if let finalError = transformedError {
//                error(finalError)
//            }
//        })
//    }
//
//    func `catch`<T>(error: @escaping (T) -> Void) -> SignalProducer<Value, Error> where T: ErrorCodeConvertible {
//        producer.on(failed: { (e: Error) in
//            var transformedError: T?
//            if let concreteError = e as? ErrorCodeConvertible {
//                transformedError = T.init(errorCode: concreteError.errorCode)
//            }
//            if let finalError = transformedError {
//                error(finalError)
//            }
//        })
//    }
//}
