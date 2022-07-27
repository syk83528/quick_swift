//
//  queue+.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import ReactiveSwift

public struct Common {
    private init() { }
    
    public static let isDebug: Bool = {
        #if DEBUG || TEST
            return true
        #else
            return false
        #endif
    }()

    public struct Queue {
        private init() { }
        
        public static var isMainThread: Bool {
            Thread.isMainThread
        }
        
        /// (单例, DispatchQueue.once).
        public static func once(token: String, block: @escaping () -> Void) {
            DispatchQueue.once(token: token, block: block)
        }
        
        /// (主线程执行, DispatchQueue.main.async).
        public static func main(_ task: @escaping () -> Void) {
            if Thread.isMainThread {
                task()
            } else {
                DispatchQueue.main.async { task() }
            }
        }
        
        public static func async(priority: DispatchQoS.QoSClass = .default, _ task: @escaping () -> Void) {
            DispatchQueue.global(qos: priority).async { task() }
        }
        
        /// (子线程执行, DispatchQueue(label: qlabel).async { }).
        ///
        /// - Parameters:
        ///   - qlabel: 子线程标识
        public static func subThread(label qlabel: String, _ task: @escaping () -> Void) {
            DispatchQueue(label: qlabel).async { task() }
        }
    }
    
    public struct Assert {
        private init() { }
        
        public static func failure(_ condition: Bool, msg message: String) {
            if condition {
                assertionFailure(message)
            }
        }
    }
    
    public struct Delay {
        private init() { }
        
        public typealias Task = (_ cancel: Bool) -> Void
        /// Running.
        @discardableResult
        public static func execution(delay dly: TimeInterval, toRun task: @escaping () -> Void) -> Task? {
            func dispatch_later(block: @escaping () -> Void) {
                let t = DispatchTime.now() + dly
                DispatchQueue.main.asyncAfter(deadline: t, execute: block)
            }
            var closure: (() -> Void)? = task
            var result: Task?
            
            let delayedClosure: Task = { cancel in
                if let internalClosure = closure {
                    if cancel == false { DispatchQueue.main.async(execute: internalClosure) }
                }
                closure = nil; result = nil
            }
            
            result = delayedClosure
            
            dispatch_later { if let delayedClosure = result { delayedClosure(false) } }
            return result
        }
        /// (取消延迟执行的任务 (执行开始前使用)).
        static func cancel(_ task: Task?) {
            task?(true)
        }
        
    }
    
    public struct Countdown {
        private init() { }
        
        /// countdown 倒计时, Singal<Bool, TimeInterval> Bool 为是否完成, timeinterval 为剩余时间(秒)
        /// - Parameters:
        ///   - duration: 持续时间
        ///   - interval: 信号发送间隔
        ///   - onScheduler: Scheduler, 一般情况下默认即可
        public static func execution(duration: TimeInterval, interval: TimeInterval, onScheduler: QueueScheduler = .main) -> Signal<(Bool, Int), Never> {
            
            let endDate = Date(timeIntervalSinceNow: duration)
            let (output, input) = Signal<(Bool, Int), Never>.pipe()
            
            let dispose = onScheduler.schedule(after: 0, interval: interval) {
                let over = endDate.timeIntervalSince1970 - onScheduler.currentDate.timeIntervalSince1970
                if over <= 0 {
                    input.send(value: (true, over.rounded().int))
                    input.sendCompleted()
                    return
                }
                input.send(value: (false, over.rounded().int))
            }
            
            return Signal<(Bool, Int), Never>.init { (observer, lifetime) in
                output.observe { (event) in
                    switch event {
                    case let .value(value):
                        observer.send(value: value)
                    case .completed:
                        observer.sendCompleted()
                        dispose?.dispose()
                    case .interrupted:
                        observer.sendInterrupted()
                    }
                }
                
                lifetime.observeEnded {
                    dispose?.dispose()
                }
            }
        }
    }
}
