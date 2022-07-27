//
//  PropertyStorage.swift
//  spsd
//
//  Created by Wildog on 12/3/19.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit

public protocol PropertyStoring {
    func property(for key: UnsafeRawPointer) -> Any?
    func setProperty(for key: UnsafeRawPointer, _ value: Any?, policy: objc_AssociationPolicy)
    
    func cgFloatProperty(for key: UnsafeRawPointer) -> CGFloat?
    func setCGFloatProperty(for key: UnsafeRawPointer, _ value: CGFloat?)
}

public extension PropertyStoring {
    /// If you need to use ASSIGN's base numeric type, please use the corresponding construction method.
    func property(for key: UnsafeRawPointer) -> Any? {
        objc_getAssociatedObject(self, key)
    }

    /// If you need to use ASSIGN's base numeric type, please use the corresponding construction method.
    func setProperty(for key: UnsafeRawPointer, _ value: Any?, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        // fix crash on 10.3.3, 准确来说是 fix crash on 32bit device 学到了
        // from: https://www.jianshu.com/p/d417e3038a04
        //     : https://juejin.im/post/6844904146114445320
        //     : https://juejin.im/post/6844903700494827534
        // 日了狗了，都统一用 retain
        // 还不能都用 retain，会导致一些属性无法释放，然后控制器也无法释放
//        if policy == .OBJC_ASSOCIATION_ASSIGN {
////            guard #available(iOS 11.0, *) else {
////                objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
////                return
////            }
//        }
        objc_setAssociatedObject(self, key, value, policy)
    }
    
    func cgFloatProperty(for key: UnsafeRawPointer) -> CGFloat? {
        guard let value = property(for: key) as? NSNumber else {
            return nil
        }
        return CGFloat(truncating: value)
    }
    func setCGFloatProperty(for key: UnsafeRawPointer, _ value: CGFloat?) {
        guard let v = value else {
            objc_setAssociatedObject(self, key, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return
        }
        objc_setAssociatedObject(self, key, NSNumber(value: Double(v)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func associatedObject<V>(_ key: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC, createIfNeed closure: () -> V) -> V {
        if let value: V = objc_getAssociatedObject(self, key) as? V {
            return value
        } else {
            let value: V = closure()
            objc_setAssociatedObject(self, key, value, policy)
            return value
        }
    }
    func setAssociatedObject<V>(_ key: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ newValue: V?) {
        objc_setAssociatedObject(self, key, newValue, policy)
    }
}

// extension UIResponder: PropertyStoring {}
extension NSObject: PropertyStoring {}
