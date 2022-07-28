//
// Created by Wildog on 12/24/19.
// Copyright (c) 2019 Wildog. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON
import common

enum Intent {
    /// 保留旧的，回退，通常用这种
    case popToExisted(_ intent: [String]? = nil)
    /// 用push的新的代替
    case pushReplace(_ intent: [String]? = nil)
    /// 保留旧的，移到栈顶
    case pushExisted(_ intent: [String]? = nil)

    var param: [String]? {
        switch self {
        case let .pushReplace(intent):
            return intent
        case let .pushExisted(intent):
            return intent
        case let .popToExisted(intent):
            return intent
        }
    }
    
}

protocol _Routable {
    var keys: [String]? { get }
    func update(value: Any, params: Dict)
    func isTypeMatched(value: Any) -> Bool
}

@propertyWrapper
class Routable<T>: NSObject, _Routable {
    typealias RoutableMappingClosure = (Dict, Routable<T>) -> T
    
    var keys: [String]?
    var customMappingClosure: RoutableMappingClosure?
    private var value: T

    init(wrappedValue: T) {
        self.value = wrappedValue
    }
    
    init(wrappedValue: T, mapping: RoutableMappingClosure? = nil) {
        self.value = wrappedValue
        self.customMappingClosure = mapping
    }
    
    init(wrappedValue: T, _ keys: [String]) {
        self.keys = keys
        self.value = wrappedValue
    }
    
    init(wrappedValue: T, _ keys: [String], mapping: RoutableMappingClosure? = nil) {
        self.keys = keys
        self.value = wrappedValue
        self.customMappingClosure = mapping
    }
    
    var wrappedValue: T {
        get {
            value
        }
        set {
            value = newValue
        }
    }
    
    private class Wrapper: HandyJSON {
        var value: T
        init(value: T) {
            self.value = value
        }
        required init() {
            fatalError("not implemented")
        }
    }

    func update(value: Any, params: Dict) {
        if let customMapping = customMappingClosure {
            wrappedValue = customMapping(params, self)
            return
        }
        if let v = value as? T {
            wrappedValue = v
            return
        }
        var wrapper = Wrapper(value: wrappedValue)
        JSONDeserializer.update(object: &wrapper, from: ["value": value])
        wrappedValue = wrapper.value
    }
    
    func isTypeMatched(value: Any) -> Bool {
        value is T
    }
}

//protocol ControllerRouterProtocol {
//    var _intent: Intent? { get }
//    func _process(params: Dict?)
//    func _after(params: Dict?)
//}

//extension ControllerRouterProtocol {
//    var _intent: Intent? { nil }
//    func _after(params: Dict?) { }
//    func _process(params: Dict?) { _processDefault(params: params) }
//    fileprivate func _processDefault(params: Dict?) {
//        defer {
//            _after(params: params)
//        }
//        guard let params = params else { return }
//        let json = JSON(params)
//        let mirror = Mirror(reflecting: self)
//        for child in mirror.children {
//            guard let routable = child.value as? _Routable else {
//                continue
//            }
//            let keys = routable.keys ?? [child.label?.substring(fromIndex: 1) ?? ""]
//            for key in keys {
//                let jsonValue = json[key]
//                if jsonValue.exists() {
//                    routable.update(value: jsonValue.object, params: params)
//                    break
//                } else if let rawValue = params[key],
//                    routable.isTypeMatched(value: rawValue) {
//                    routable.update(value: rawValue, params: params)
//                    break
//                }
//            }
//        }
//    }
//}
extension UIViewController {
    @objc var intent: Any? { nil }
}
// Swift shit
//extension UIViewController: ControllerRouterProtocol {
//    final var _intent: Intent? { intent as? Intent }
    // ViewController 如需要请重写以下方法，不要重写协议里"_开头"的方法
//    @objc var intent: Any? { nil }
//}

//class RouterAction: NSObject, ControllerRouterProtocol {
//    required override init() {}
//    func execute(_ params: Dict) {}
//}
//
//class ClosureRouterAction: RouterAction {
//    var closure: ((Dict) -> Void)?
//    convenience init(closure: ((Dict) -> Void)?) {
//        self.init()
//        self.closure = closure
//    }
//    override func execute(_ params: Dict) {
//        closure?(params)
//    }
//}

extension JSON {
    public var stringConverted: String? {
        let s = stringValue
        guard s != "" else { return nil }
        return s
    }
}

