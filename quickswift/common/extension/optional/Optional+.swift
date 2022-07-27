//
//  Optional+.swift
//  IWBaseKits
//
//  Created by 未来 on 2019/4/3.
//  Copyright © 2019 iWECon. All rights reserved.
//

#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

public protocol Optionalable: ExpressibleByNilLiteral {

    associatedtype Wrapped

    var wrapped: Wrapped? { get }

    init(_ some: Wrapped)
}

extension Optional: Optionalable {
    public var wrapped: Wrapped? {
        switch self {
        case .some(let wrapped):
            return wrapped
        case .none:
            return nil
        }
    }
}

public extension Optional {
    
    /// is nil(none)
    var isNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
    
    /// has some value.
    var isSome: Bool {
        switch self {
        case .some: return true
        default: return false
        }
    }
    
    var any: Any {
        return self as Any
    }
    
    /// Returns value.
    /// (返回解析值, 若目标值为nil 则直接崩溃).
    var wrapValue: Wrapped {
        if self.isSome { return self! }
        fatalError("Unexpectedly found nil while unwrapping an Optional value (解析失败, 目标值为nil).")
    }
    
    /// Return the value of the Optional or the `default` parameter
    /// (如果目标有值则返回目标值, 否则返回defualt).
    func or(_ default: Wrapped) -> Wrapped {
        return self ?? `default`
    }
    
    /// Returns the unwrapped value of the optional *or*
    /// the result of an expression `else`
    /// I.e. optional.or(else: log("Arrr"))
    func or(else: @autoclosure () -> Wrapped) -> Wrapped {
        return self ?? `else`()
    }
    
    /// Returns the unwrapped value of the optional *or*
    /// the result of calling the closure `else`
    /// I.e. optional.or(else: {
    /// ... do a lot of stuff
    /// })
    func or(else: () -> Wrapped) -> Wrapped {
        return self ?? `else`()
    }
    
    /// Returns the unwrapped contents of the optional if it is not empty
    /// If it is empty, throws exception `throw`
    func or(throw exception: Error) throws -> Wrapped {
        guard let unwrapped = self else { throw exception }
        return unwrapped
    }
    
    /// (self 且 with 有值, 则返回解包后的结果「以元组类型返回」, 否则返回 nil).
    ///
    ///     let hello: String? = "hello"
    ///     let world: String? = "world"
    ///     hello.zip2(with: world) -> ("hello", "world")
    func zip2<A>(with other: A?) -> (Wrapped, A)? {
        guard let first = self, let second = other else { return nil }
        return (first, second)
    }
    
    /// (强制解包, 失败则触发 fatalError(message)).
    func despair(_ message: String) -> Wrapped {
        guard let value = self else { fatalError(message) }
        return value
    }
    
    /// 如果有值，则解包后会加上 str 后缀
    /// 如果没值，则会返回 def
    func unwrapSuffix(str: String, def: String) -> String {
        guard let value = self else {
            return def
        }
        return "\(value)\(str)"
    }
}

public extension Optional where Wrapped == Bool {
    
    static func << <T: Any>(lhs: Bool?, rhs: (T, T)) -> T {
        lhs.or(false) ? rhs.0 : rhs.1
    }
    /// rhs 第一个参数是给 lhs 提供的默认值
    static func << <T: Any>(lhs: Bool?, rhs: (Bool, T, T)) -> T {
        lhs.or(rhs.0) ? rhs.1 : rhs.2
    }
}

public extension Optional where Wrapped == String {
    
    var count: Int {
        if let value = wrapped {
            return value.count
        }
        return 0
    }
    
    /// Returns "", if the optional value isNone
    var orEmpty: String {
        return self ?? ""
    }
    
    /// just get image-file from Assets.xcassets
    var getImage: UIImage? {
        if self.isNone {
            return nil
        }
        return UIImage(named: self.wrapValue)
    }
    
    func empty(_ defaultValue: String) -> String {
        (self ?? "").empty(defaultValue)
    }
}

public extension Optional where Wrapped: Collection {
    
    var count: Int {
        if let value = wrapped {
            return value.count
        }
        return 0
    }
}

public extension Optional where Wrapped: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        guard let lhsWrapped = lhs.wrapped else {
            return true
        }
        guard let rhsWrapped = rhs.wrapped else {
            return false
        }
        return lhsWrapped < rhsWrapped
    }
    static func <= (lhs: Self, rhs: Self) -> Bool {
        guard let lhsWrapped = lhs.wrapped else {
            return true
        }
        guard let rhsWrapped = rhs.wrapped else {
            return false
        }
        return lhsWrapped <= rhsWrapped
    }
    static func >= (lhs: Self, rhs: Self) -> Bool {
        guard let lhsWrapped = lhs.wrapped else {
            return false
        }
        guard let rhsWrapped = rhs.wrapped else {
            return true
        }
        return lhsWrapped >= rhsWrapped
    }
    static func > (lhs: Self, rhs: Self) -> Bool {
        guard let lhsWrapped = lhs.wrapped else {
            return false
        }
        guard let rhsWrapped = rhs.wrapped else {
            return true
        }
        return lhsWrapped > rhsWrapped
    }
}

// swiftlint:disable force_cast
public extension Optional where Wrapped == Any {
    /// as? String
    var string: String? {
        return self as? String
    }
    /// as! String
    var stringValue: String {
        return self as! String
    }
    
    /// ( as? Bool).or(false)
    var bool: Bool {
        return (self as? Bool).or(false)
    }
    
    /// as? Int
    var int: Int? {
        return self as? Int
    }
    /// as! Int
    var intValue: Int {
        return self as! Int
    }
    /// as? Float
    var float: Float? {
        return self as? Float
    }
    /// as! Float
    var floatValue: Float {
        return self as! Float
    }
    /// as? TimeInterval
    var interval: TimeInterval? {
        self as? TimeInterval
    }
    /// as? CGFloat
    var cgFloat: CGFloat? {
        return self as? CGFloat
    }
    /// as! CGFloat
    var cgFloatValue: CGFloat {
        return self as! CGFloat
    }
    /// as? CGSize
    var size: CGSize? {
        return self as? CGSize
    }
    /// as! CGSize
    var sizeValue: CGSize {
        return self as! CGSize
    }
    /// as? CGRect
    var rect: CGRect? {
        return self as? CGRect
    }
    /// as! CGRect
    var rectValue: CGRect {
        return self as! CGRect
    }
    /// as? `[String: Any]`
    var dictionary: [String: Any]? {
        return self as? [String: Any]
    }
    /// as! `[String: Any]`
    var dictionaryValue: [String: Any] {
        return self as! [String: Any]
    }
    /// as? `[AnyHashable: Any]`
    var anyDict: [AnyHashable: Any]? {
        self as? [AnyHashable: Any]
    }
    /// as! `[AnyHashable: Any]`
    var anyDictValue: [AnyHashable: Any] {
        self as! [AnyHashable: Any]
    }
}
// swiftlint:enable force_cast

extension OptionSet where RawValue == Int {
    
    /// return true when any one contains
    func contains(_ members: Self.Element...) -> Bool {
        for member in members {
            if self.contains(member) {
                return true
            }
        }
        return false
    }
}
