//
//  Reactive+Weakify.swift
//  spsd
//
//  Created by iWw on 2022/2/22.
//  Copyright © 2022 未来. All rights reserved.
//

import UIKit
import ReactiveSwift

// from RxSwift: https://github.com/RxSwiftCommunity/RxSwiftExt/issues/14
fileprivate extension Signal {
    /**
     Leverages instance method currying to provide a weak wrapper around an instance function
     
     - parameter obj:    The object that owns the function
     - parameter method: The instance function represented as `InstanceType.instanceFunc`
     */
    func weakify<Object: AnyObject, Input>(_ obj: Object, method: ((Object) -> (Input) -> Void)?) -> ((Input) -> Void) {
        return { [weak obj] value in
            guard let obj = obj else { return }
            method?(obj)(value)
        }
    }
    
    func weakify<Object: AnyObject>(_ obj: Object, method: ((Object) -> () -> Void)?) -> (() -> Void) {
        return { [weak obj] in
            guard let obj = obj else { return }
            method?(obj)()
        }
    }
}
// from RxSwift: https://github.com/RxSwiftCommunity/RxSwiftExt/issues/14
fileprivate extension SignalProducer {
    /**
     Leverages instance method currying to provide a weak wrapper around an instance function
     
     - parameter obj:    The object that owns the function
     - parameter method: The instance function represented as `InstanceType.instanceFunc`
     */
    func weakify<Object: AnyObject, Input>(_ obj: Object, method: ((Object) -> (Input) -> Void)?) -> ((Input) -> Void) {
        return { [weak obj] value in
            guard let obj = obj else { return }
            method?(obj)(value)
        }
    }
    
    func weakify<Object: AnyObject>(_ obj: Object, method: ((Object) -> () -> Void)?) -> (() -> Void) {
        return { [weak obj] in
            guard let obj = obj else { return }
            method?(obj)()
        }
    }
    
    func weakify<Object: AnyObject, Input>(_ obj: Object, method: ((Object) -> (Input) -> SignalProducer<Value, Error>)?) -> ((Input) -> SignalProducer<Value, Error>) {
        return { [weak obj] value in
            guard let obj = obj else { return .empty }
            return method?(obj)(value) ?? .empty
        }
    }
}


public extension Signal where Error == Never {
    @discardableResult func observeValues<Object: AnyObject>(weak object: Object, _ onValue: @escaping (Object) -> (Value) -> Void) -> Disposable? {
        observeValues(weakify(object, method: onValue))
    }
}

// MARK: SignalProducer on...
public extension SignalProducer  {
    
    // MARK: For Weakly object
    @discardableResult func starting<Object: AnyObject>(weak object: Object, _ onStarting: @escaping (Object) -> () -> Void) -> SignalProducer<Value, Error> {
        on(starting: weakify(object, method: onStarting))
    }
    @discardableResult func started<Object: AnyObject>(weak object: Object, _ onStarted: @escaping (Object) -> () -> Void) -> SignalProducer<Value, Error> {
        on(started: weakify(object, method: onStarted))
    }
    @discardableResult func terminated<Object: AnyObject>(weak object: Object, _ onTerminated: @escaping (Object) -> () -> Void) -> SignalProducer<Value, Error> {
        on(terminated: weakify(object, method: onTerminated))
    }
    @discardableResult func value<Object: AnyObject>(weak object: Object, _ onValue: @escaping (Object) -> (Value) -> Void) -> SignalProducer<Value, Error> {
        on(value: weakify(object, method: onValue))
    }
    @discardableResult func failed<Object: AnyObject>(weak object: Object, _ onFailed: @escaping (Object) -> (Error) -> Void) -> SignalProducer<Value, Error> {
        on(failed: weakify(object, method: onFailed))
    }
    
    @discardableResult func concat<Object: AnyObject>(weak object: Object, _ transform: @escaping (Object) -> (Value) -> SignalProducer<Value, Error>) -> SignalProducer<Value, Error> {
        producer.flatMap(.latest, weakify(object, method: transform))
    }
}
