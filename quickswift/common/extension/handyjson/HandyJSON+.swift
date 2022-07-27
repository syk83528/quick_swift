//
//  HandyJSON+.swift
//  spsd
//
//  Created by 未来 on 2020/1/4.
//  Copyright © 2020 Wildog. All rights reserved.
//

import UIKit
import HandyJSON

public extension HandyJSON {
   
    /// 仅包含
    /// - Parameter includes: 包含的参数名，需要传服务端原始参数名
    /// - Returns: dict
    func toJSON(includes: [String]) -> [String: Any]? {
        self.toJSON()?.filter({ includes.contains($0.0) })
    }
    
    /// 仅忽略
    /// - Parameter ignores: 忽略的参数名，需要传服务器原始参数名
    /// - Returns: dict
    func toJSON(ignores: [String]) -> [String: Any]? {
        self.toJSON()?.filter({ !ignores.contains($0.0) })
    }
}

/// 如果需要做 toJSON 之类的处理，用 `mapper <<< self.xxx <-- TransformOptionSet<范型>()`
protocol HandyJSONOptionSet: HandyJSONEnum { }

extension String: HandyJSON {}
protocol HandyJSONNumber: HandyJSONCustomTransformable { }

private func convertAnyToString(object: Any) -> String {
    "\(object)".replace("Optional(", to: "").replace(")", to: "")
}

extension CGFloat: HandyJSONNumber {
    public static func _transform(from object: Any) -> CGFloat? {
        return convertAnyToString(object: object).cgFloat
    }
    public func _plainValue() -> Any? {
        return self
    }
}

extension Int: HandyJSONNumber {
    public static func _transform(from object: Any) -> Int? {
        Int(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}

extension UInt: HandyJSONNumber {
    public static func _transform(from object: Any) -> UInt? {
        UInt(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}
extension Int8: HandyJSONNumber {
    public static func _transform(from object: Any) -> Int8? {
        Int8(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}
extension Int16: HandyJSONNumber {
    public static func _transform(from object: Any) -> Int16? {
        Int16(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}
extension Int32: HandyJSONNumber {
    public static func _transform(from object: Any) -> Int32? {
        Int32(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}
extension Int64: HandyJSONNumber {
    public static func _transform(from object: Any) -> Int64? {
        Int64(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}
extension UInt8: HandyJSONNumber {
    public static func _transform(from object: Any) -> UInt8? {
        UInt8(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}
extension UInt16: HandyJSONNumber {
    public static func _transform(from object: Any) -> UInt16? {
        UInt16(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}
extension UInt32: HandyJSONNumber {
    public static func _transform(from object: Any) -> UInt32? {
        UInt32(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}
extension UInt64: HandyJSONNumber {
    public static func _transform(from object: Any) -> UInt64? {
        UInt64(convertAnyToString(object: object))
    }
    public func _plainValue() -> Any? {
        return self
    }
}
