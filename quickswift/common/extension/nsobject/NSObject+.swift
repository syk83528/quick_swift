//
//  NSObject+.swift
//  spsd
//
//  Created by iWw on 8/10/20.
//  Copyright © 2020 未来. All rights reserved.
//

import UIKit

extension NSObject {
    /// get the instance's class name, will be add namespace prefix like: taoqu.ViewController
    var clazzName: String {
        NSStringFromClass(type(of: self))
    }
    /// 带命名空间(duomi.XXXController)
    static var clazzName: String {
        NSStringFromClass(self)
    }
    
    /// 带命名空间(duomi.XXXController)
    public var classFullName: String {
        return type(of: self).classFullName
    }
    /// 带命名空间
    public static var classFullName: String {
        return NSStringFromClass(self)
    }
    /// 不带命名空间
    public var className: String {
        return type(of: self).className
    }
    /// 不带命名空间
    public static var className: String {
        return String(classFullName.split(separator: ".").last ?? "")
    }
}
