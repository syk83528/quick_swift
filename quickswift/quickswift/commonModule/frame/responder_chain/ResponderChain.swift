//
// Created by Wildog on 12/18/19.
// Copyright (c) 2019 Wildog. All rights reserved.
//

import UIKit
import IGListKit
import common

public struct NonnullParam {
    var values: [String: Any]

    init(values: [String: Any?]) {
        self.values = values.filterNil()
    }
    
    subscript(key: String) -> Any? {
        get {
            values[key]
        }
        set {
            values[key] = newValue
        }
    }
    
    subscript<T>(key: String, type: T.Type) -> T? {
        get {
            values[key] as? T
        }
    }
}

extension NonnullParam: Equatable {
    public static func == (lhs: NonnullParam, rhs: NonnullParam) -> Bool {
        NSDictionary(dictionary: lhs.values).isEqual(to: rhs.values)
    }
}

extension NonnullParam: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any?)...) {
        var values: [String: Any?] = [:]
        for (key, value) in elements {
            values[key] = value
        }
        self.init(values: values)
    }
}

typealias ResponderParam = [String: Any]
typealias RespondableHandler = (ResponderParam?) -> Void
typealias RespondableHandlerProvider<ClassType> = (ClassType) -> RespondableHandler

extension ResponderParam {
    var source: Any? {
        return self["__source"]
    }
}

protocol Responder: PropertyStoring {
    var nextResponder: Responder? { get }
}

extension UIResponder: Responder {
    var nextResponder: Responder? {
        get {
            (property(for: &Keys.Responder.nextResponder) as? Responder) ?? next
        }
        set {
            setProperty(for: &Keys.Responder.nextResponder, newValue, policy: .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

extension ListSectionController: Responder {
    var nextResponder: Responder? {
        get {
            property(for: &Keys.Responder.nextResponder) as? Responder
        }
        set {
            setProperty(for: &Keys.Responder.nextResponder, newValue, policy: .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

protocol _Respondable {
    func isRespondable(with: Any) -> Bool
    var identifier: String? { get }
    func doRespond(with: Any, param: ResponderParam?) -> Bool
}

@propertyWrapper
class Respondable<T>: _Respondable {

    var identifier: String?
    private var handler: RespondableHandlerProvider<T>?
    
    init(wrappedValue: RespondableHandlerProvider<T>?) {
        self.handler = wrappedValue
    }

    init(wrappedValue: RespondableHandlerProvider<T>?, _ identifier: String) {
        self.identifier = identifier
        self.handler = wrappedValue
    }

    var wrappedValue: RespondableHandlerProvider<T>? {
        get {
            handler
        }
        set {
            handler = newValue
        }
    }
    
    func isRespondable(with: Any) -> Bool {
        return with is T
    }
    
    func doRespond(with: Any, param: ResponderParam?) -> Bool {
        guard let handler = handler,
            let with = with as? T else { return false }
        handler(with)(param)
        return true
    }
}

fileprivate extension Keys {
    struct Responder {
        static var designatedResponder = "Keys.Responder.designatedResponder"
        static var nextResponder = "Keys.Responder.nextResponder"
    }
}

extension Responder {
    var designatedResponder: Responder? {
        get {
            property(for: &Keys.Responder.designatedResponder) as? Responder
        }
        nonmutating set {
            setProperty(for: &Keys.Responder.designatedResponder, newValue, policy: .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    // dispatch func 适用于指定响应类和方法，用于替代 delegate
    // 适用于绝大多数使用场景
    func dispatch<T>(func: (T) -> (ResponderParam?) -> Void, param: NonnullParam? = nil, initiate: Bool = true) {
        var paramsValue = param?.values ?? [:]
        if initiate {
            paramsValue["__source"] = self
        }
        if respondIfPossible(func: `func`, param: paramsValue) {
            return
        }
        (designatedResponder ?? nextResponder)?.dispatch(
            func: `func`,
            param: NonnullParam(values: paramsValue),
            initiate: false)
    }
    fileprivate func respondIfPossible<T>(func: (T) -> (ResponderParam?) -> Void, param: ResponderParam?) -> Bool {
        guard let responder = self as? T else { return false }
        `func`(responder)(param)
        return true
    }
    
    // dispatch event 适用于不确定响应类或者有定制响应链需求的情况
    // 主要适用于通用控件
    func dispatch(event identifier: String, param: NonnullParam? = nil, initiate: Bool = true) {
        var paramsValue = param?.values ?? [:]
        if initiate {
            paramsValue["__source"] = self
        }
        if respondIfPossible(provider: self, identifier: identifier, param: paramsValue) {
            return
        }
        (designatedResponder ?? nextResponder)?.dispatch(
            event: identifier,
            param: NonnullParam(values: paramsValue),
            initiate: false)
    }
    fileprivate func respondIfPossible(provider: Any, identifier: String, param: ResponderParam?) -> Bool {
        let mirror = Mirror(reflecting: provider)
        for child in mirror.children {
            guard let Respondable = child.value as? _Respondable, Respondable.isRespondable(with: provider), (Respondable.identifier ?? child.label?.substring(fromIndex: 1)) == identifier else {
                continue
            }
            return Respondable.doRespond(with: provider, param: param)
        }
        return false
    }
}
