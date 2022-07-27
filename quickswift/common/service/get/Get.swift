//
//  Get.swift
//  spsd
//
//  Created by suyikun on 2021/12/29.
//  Copyright © 2021 未来. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa

class Get {
    static let to = Get()
    private init() {}
    
    private var controllerMap = NSMapTable<NSString, GetController>.strongToWeakObjects()
    
    let (input, output) = Signal<String, Never>.pipe()
    
//    private let futureControllerSignal = Signal<Any, Never>.pipe()
    
    static func put(_ c: GetController, identify: String? = nil, operation: GetOperation = .ignore) {
        let key = (c.className + (identify ?? "")).nsString
        if let _ = to.controllerMap.object(forKey: key) {
            switch operation {
            case .ignore:
                return
            case .replace:
                to.controllerMap.setObject(c, forKey: key)
//                to.futureControllerSignal.input.send(value: c)
            }
        } else {
            to.controllerMap.setObject(c, forKey: key)
//            to.futureControllerSignal.input.send(value: c)
        }
    }
    
    
    static func find<T: GetController>(_ type: T.Type, identify: String? = nil) -> T? {
        let key = (type.className + (identify ?? "")).nsString
        return to.controllerMap.object(forKey: key) as? T
    }
    
//    /// 等待未来的 controller
//    static func futureFind<T: GetController>(_ type: T.Type, identify: String? = nil) -> SignalProducer<T?, Never>{
//        let key = (type.className + (identify ?? "")).nsString
//        return .init { o, lifetime in
//            if let controller = to.controllerMap.object(forKey: key) as? T {
//                o.send(value: controller)
//            } else {
//                let dis = Get.to.futureControllerSignal.output.observeValues { any in
//                    if let controller = any as? T {
//                        o.send(value: controller)
//                        o.sendCompleted()
//                    }
//                }
//                lifetime.observeEnded {
//                    dis?.dispose()
//                }
//            }
//        }
//    }
    
//    static func toName(name: String, argument: Dict?) {
//        GetRouter.to.toName(name: name, argument: argument)
//    }
}
