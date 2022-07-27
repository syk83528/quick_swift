//
//  Reactive+.swift
//  spsd
//
//  Created by Wildog on 12/5/19.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

// MARK: - SignalProducer
public extension SignalProducer {
    
    @available(*, deprecated, message: "用原生的 observe(on:), UI 线程不要用 QueueScheduler.main 用 UIScheduler()")
    var onMain: SignalProducer {
        observe(on: QueueScheduler.main)
    }
    
    @available(*, deprecated, message: "用原生的 observe(on:), UI 线程不要用 QueueScheduler.main 用 UIScheduler()")
    var onUIScheduler: SignalProducer {
        observe(on: UIScheduler())
    }
    
    @discardableResult
    func on(success: ((Value) -> Void)? = nil, failure: ((Error) -> Void)? = nil, finally: (() -> Void)? = nil) -> SignalProducer<Value, Error> {
        on(failed: failure, terminated: finally, value: success)
    }
    // on:value == on:next == on:success == success:
    @discardableResult
    func success(_ closure: @escaping (Value) -> Void) -> SignalProducer<Value, Error> {
        on(value: closure)
    }
    
    @discardableResult
    func failure(_ closure: @escaping (Error) -> Void) -> SignalProducer<Value, Error> {
        on(failure: closure)
    }
    
    @discardableResult
    func finally(_ closure: @escaping () -> Void) -> SignalProducer<Value, Error> {
        on(terminated: closure)
    }
    
    @discardableResult
    func start(success: ((Value) -> Void)? = nil, failure: ((Error) -> Void)? = nil, finally: (() -> Void)? = nil) -> Disposable {
        on(success: success, failure: failure, finally: finally).start()
    }
    
    @discardableResult
    func startWithSuccess(_ success: ((Value) -> Void)?) -> Disposable {
        on(value: success).start()
    }
    
    func ignoreErrors() -> SignalProducer<Value, Never> {
        flatMapError { _ in SignalProducer<Value, Never>.empty }
    }
    
    func mapError(value: Value) -> SignalProducer<Value, Error> {
        flatMapError { (_) -> SignalProducer<Value, Error> in
            return .init(value: value)
        }
    }
    
    var action: Action<(), Value, Error> {
        Action { self }
    }

    var executable: CocoaAction<Any> {
        CocoaAction<Any>(Action { self })
    }
    
    var executeButton: CocoaAction<UIButton> {
        execute(UIButton.self)
    }

    func execute<B>(_ sender: B.Type) -> CocoaAction<B> {
        CocoaAction<B>(Action { self })
    }

    func execute<P: PropertyProtocol>(when: P) -> CocoaAction<Any> where P.Value == Bool {
        let action = CocoaAction<Any>(Action(enabledIf: when, execute: { self }))
        action.isUserEnabled = Property(capturing: when)
        return action
    }
}

// MARK: - Action where Input == ()
public extension Action where Input == () {
    var executable: CocoaAction<Any> {
        CocoaAction<Any>(self)
    }
    
    var executeButton: CocoaAction<UIButton> {
        execute(UIButton.self)
    }

    func execute<B>(_ sender: B.Type) -> CocoaAction<B> {
        CocoaAction<B>(self)
    }
    
    @discardableResult
    static func <~ (provider: BindingTarget<Output>, source: Action<Input, Output, Error>) -> Disposable? {
        provider <~ source.values
    }
    
    @discardableResult
    static func <~ (provider: BindingTarget<Output?>, source: Action<Input, Output, Error>) -> Disposable? {
        provider <~ source.values
    }
}

public extension SignalProducer {

    func retry(when: @escaping ((Error) -> Bool), upTo: Int = 3, interval: TimeInterval = 3, scheduler: DateScheduler = QueueScheduler.main) -> SignalProducer<Value, Error> {
        precondition(upTo >= 0)

        if upTo == 0 {
            return producer
        }

        return flatMapError { error -> SignalProducer<Value, Error> in
            var p = SignalProducer<Value, Error>(error: error)
            if !when(error) {
                return p
            }
            let delay = interval / Double(upTo)
            commonllog("🔄\(upTo - 1 == 0 ? "Final retry" : "Retry") after \(delay) seconds")
            p = SignalProducer.empty
                .delay(delay, on: scheduler)
                .concat(self.producer.retry(when: when,
                                            upTo: upTo - 1,
                                            interval: interval,
                                            scheduler: scheduler))
            return p
        }
    }
}

public extension SignalProducer {
    func then<U>(_ transform: @escaping (Value) -> SignalProducer<U, Error>) -> SignalProducer<U, Error> {
        producer.flatMap(.concat) { v -> SignalProducer<U, Error> in
            return transform(v)
        }
    }
}

public extension ReactiveExtensionsProvider {
    var r: ReactiveSwift.Reactive<Self> { reactive }
    static var r: ReactiveSwift.Reactive<Self>.Type { reactive }
}

infix operator <~? : BindingPrecedence

public extension BindingTargetProvider {
    @discardableResult
    static func <~?
            <Source: BindingSource>
            (provider: Self, source: Source) -> Disposable?
            where Source.Value == Value {
        source.producer.take(during: provider.bindingTarget.lifetime).skip(first: 1).startWithValues(provider.bindingTarget.action)
    }

    @discardableResult
    static func <~?
            <Source: BindingSource>
            (provider: Self, source: Source) -> Disposable?
            where Value == Source.Value? {
        provider <~? source.producer.map(Optional.init)
    }
}


fileprivate extension Keys {
    struct CocoaAction {
        static var isUserEnabled = "CocoaAction.isUserEnabled"
    }
}

public extension CocoaAction {

    var isUserEnabled: Property<Bool>? {
        get {
            property(for: &Keys.CocoaAction.isUserEnabled) as? Property<Bool>
        }
        set {
            setProperty(for: &Keys.CocoaAction.isUserEnabled, newValue)
        }
    }
}

public extension Action {
    @discardableResult
    func start(_ input: Input) -> Disposable {
        apply(input).start()
    }
}

public protocol KVObserveExtensionsProvider {}

public extension KVObserveExtensionsProvider {
    var o: KVObserve<Self> {
        KVObserve(self)
    }

    static var o: KVObserve<Self>.Type {
        KVObserve<Self>.self
    }
}

public struct KVObserve <Base> {
    public let base: Base

    fileprivate init(_ base: Base) {
        self.base = base
    }
}

public extension KVObserve where Base: NSObject {

    subscript<Value>(keyPath: KeyPath<Base, Value>) -> SignalProducer<Value, Never> {
        self.base.reactive.producer(for: keyPath).take(duringLifetimeOf: self.base)
    }
    subscript<Value>(keyPath: KeyPath<Base, Value?>) -> SignalProducer<Value?, Never> {
        self.base.reactive.producer(for: keyPath).take(duringLifetimeOf: self.base)
    }
    subscript(keyPath: String) -> SignalProducer<Any?, Never> {
        self.base.reactive.producer(forKeyPath: keyPath).take(duringLifetimeOf: self.base)
    }
}

public protocol KVCBindingTargetExtensionsProvider {}

public extension KVCBindingTargetExtensionsProvider {
    var p: KVCBindingTarget<Self> {
        KVCBindingTarget(self)
    }

    static var p: KVCBindingTarget<Self>.Type {
        KVCBindingTarget<Self>.self
    }
}

public struct KVCBindingTarget <Base> {
    public let base: Base

    fileprivate init(_ base: Base) {
        self.base = base
    }
}

public extension KVCBindingTarget where Base: NSObject {

    subscript<Value>(keyPath: ReferenceWritableKeyPath<Base, Value>) -> BindingTarget<Value> {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        return self.base.reactive.makeBindingTarget { (b: Base, v: Value) in
            b.setValue(v, forKey: key)
        }
    }
    subscript<Value>(keyPath: ReferenceWritableKeyPath<Base, Value?>) -> BindingTarget<Value?> {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        return self.base.reactive.makeBindingTarget { (b: Base, v: Value?) in
            b.setValue(v, forKey: key)
        }
    }
}

extension NSObject: KVObserveExtensionsProvider, KVCBindingTargetExtensionsProvider {}

public extension Signal {
    func ignoreErrors() -> Signal<Value, Never> {
        flatMapError { _ in Signal<Value, Never>.empty }
    }
    
    func mapError(value: Value) -> Signal<Value, Error> {
        flatMapError { (_) -> SignalProducer<Value, Error> in
            return .init(value: value)
        }
    }

    @discardableResult
    func `do`(_ closure: @escaping () -> Void) -> Disposable? {
        ignoreErrors().observeValues { (_: Value) in
            closure()
        }
    }
    
    @discardableResult
    func `do`(next action: @escaping (Value) -> Void) -> Disposable? {
        ignoreErrors().observeValues(action)
    }
    
    @discardableResult
    func on(next: @escaping (Value) -> Void) -> Signal<Value, Error> {
        on(value: next)
    }
    
    func producer() -> SignalProducer<Value, Error> {
        SignalProducer<Value, Error>.init(self)
    }
}

public extension Signal where Error == Never {
    func property(initial: Value) -> Property<Value> {
        Property.init(initial: initial, then: self)
    }
    
    @available(*, deprecated, message: "用原生的 observe(on:), UI 线程不要用 QueueScheduler.main 用 UIScheduler()")
    var onMain: Signal<Value, Error> {
        signal.observe(on: QueueScheduler.main)
    }
    
    @available(*, deprecated, message: "用原生的 observe(on:), UI 线程不要用 QueueScheduler.main 用 UIScheduler()")
    var onUIScheduler: Signal<Value, Error> {
        signal.observe(on: UIScheduler())
    }
}

public extension SignalProducer where Error == Never {
    func property(initial: Value) -> Property<Value> {
        Property.init(initial: initial, then: self)
    }
}

public extension Reactive where Base: UIGestureRecognizer {
    
    /// Sets whether the control is enabled.
    var isEnabled: BindingTarget<Bool> {
        return makeBindingTarget { $0.isEnabled = $1 }
    }

}


public extension SignalProducer where Value == Bool, Error == Never {
    
    func mapReversed() -> SignalProducer<Value, Error> {
        map({ !$0 })
    }
}

public extension SignalProducer where Value == String, Error == Never {
    
    func bind(to: MutableProperty<String>) {
        to <~ self
    }
}

public extension SignalProducer where Value: Optionalable {
    
    func filterNil() -> SignalProducer<Value, Never> {
        producer.ignoreErrors().filter({ $0.wrapped == nil })
    }
}

public extension QueueScheduler {
    @discardableResult
    func schedule(after timeInterval: TimeInterval, action: @escaping () -> Void) -> Disposable? {
        schedule(after: Date() + timeInterval, action: action)
    }
        
    @discardableResult
    func schedule(after timeInterval: TimeInterval, interval: TimeInterval, action: @escaping () -> Void) -> Disposable? {
        schedule(after: timeInterval, interval: interval, leeway: interval * 0.1, action: action)
    }
    
    @discardableResult
    func schedule(after timeInterval: TimeInterval, interval: TimeInterval, leeway: TimeInterval, action: @escaping () -> Void) -> Disposable? {
        schedule(after: Date() + timeInterval, interval: DispatchTimeInterval.milliseconds(Int(interval * 1000)), leeway: DispatchTimeInterval.milliseconds(Int(interval * 1000)), action: action)
    }
}


public extension SignalProducer where Value: Sequence {
    @discardableResult
    func compactMap<T>(transform: @escaping (Value.Element) -> T?) -> SignalProducer<[T], Error> {
        producer.map { (sequence) -> [T] in
            sequence.compactMap(transform)
        }
    }
    
    @discardableResult
    func compactMap<T>(type: T.Type) -> SignalProducer<[T], Error> {
        producer.compactMap { (elem) -> T? in
            elem as? T
        }
    }
}

public extension Signal where Value: Sequence {
    func compactMap<T>(transform: @escaping (Value.Element) -> T?) -> Signal<[T], Error> {
        map { (sequence) -> [T] in
            sequence.compactMap(transform)
        }
    }
    
    func compactMap<T>(type: T.Type) -> Signal<[T], Error> {
        compactMap { (elem) -> T? in
            elem as? T
        }
    }
}

public extension Signal where Value == String, Error == Never {
    
    /// 返回 Bool
    /// - Parameters:
    ///   - min: 大于 min
    ///   - max: 小于等于 max
    func countInterval(min: Int, max: Int) -> Signal<Bool, Never> {
        map({ $0.count > min && $0.count <= max })
    }
    
    func count() -> Signal<Int, Never> {
        map({ $0.count })
    }
}

public extension Reactive where Base: UIBarButtonItem {
    func `do`(_ closure: @escaping ((Base) -> Void)) {
        pressed = SignalProducer<(), Never>.init { [weak base] (observer, _) in
            observer.sendCompleted()
            guard let base = base else { return }
            closure(base)
        }.execute(Base.self)
    }
}

