//
//  NotificationName.swift
//  spsd
//
//  Created by 未来 on 2019/12/20.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

public struct Notif: RawRepresentable {
    
    public typealias RawValue = String
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ raw: String) {
        self.init(rawValue: raw)
    }
    
    private var nc = NotificationCenter.default
    
    public var name: Notification.Name {
        return Notification.Name(self.rawValue)
    }
    
    public func add(observer: Any, selector: Selector, object: Any? = nil) {
        nc.addObserver(observer, selector: selector, name: self.name, object: object)
    }
    
    public func remove(observer: Any, object: Any? = nil) {
        nc.removeObserver(observer, name: self.name, object: object)
    }
    
    public func post(userInfo: [AnyHashable: Any]? = nil, object: Any? = nil) {
        nc.post(name: self.name, object: object, userInfo: userInfo)
    }
    
    /// 有歧义, 暂移除
    // func post(notification: Notification) {
    //     // // name: 为notification.name
    //     // NotificationCenter.default.post(notification)
    //     // or
    //     // // name: 为self.name
    //     // post(userInfo: notification.userInfo, object: notification.object)
    // }
    
    /// 监听, 绑定生命周期
    /// - Parameters:
    ///   - obj: 生命周期绑定
    ///   - object: object description
    /// - Returns: signal
    public func listen(duringOf obj: AnyObject, object: Any? = nil) -> Signal<Notification, Never> {
        observer(object).take(duringLifetimeOf: obj)
    }
    
    /// 监听, 可自定义生命周期; 如需要绑定生命周期用 listen(duringOf:,object:)
    /// - Parameter object: object description
    /// - Returns: signal，可自定义生命周期, 选择 take 或者 duringOfObject
    public func observer(_ object: Any? = nil) -> Signal<Notification, Never> {
        nc.reactive.notifications(forName: self.name, object: object as AnyObject?)
    }
}


public extension Notification.Name {
    
    func add(observer: Any, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: self, object: object)
    }
    
    func post(userInfo: [AnyHashable: Any]? = nil, object: Any? = nil) {
        NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
    }
    
    /// 有歧义, 暂移除
    // func post(notification: Notification) {
    //     // NotificationCenter.default.post(notification)
    //     // or
    //     //post(userInfo: notification.userInfo, object: notification.object)
    // }
    
    func listen(duringOf obj: AnyObject, object: Any? = nil) -> Signal<Notification, Never> {
        observer(object).take(duringLifetimeOf: obj)
    }
    
    func observer(_ object: Any? = nil) -> Signal<Notification, Never> {
        NotificationCenter.default.reactive.notifications(forName: self, object: object as AnyObject?)
    }
}

public extension Signal where Value == Notification, Error == Never {
    
    @discardableResult
    func observeObject(_ object: @escaping (Any?) -> Void) -> Disposable? {
        observeValues { (notify) in
            object(notify.object)
        }
    }
    
    @discardableResult
    func observeUserInfo(_ userInfo: @escaping (AnyDict?) -> Void) -> Disposable? {
        observeValues { (notify) in
            userInfo(notify.userInfo)
        }
    }
    
}
