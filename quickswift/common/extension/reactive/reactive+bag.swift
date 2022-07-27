//
//  reactive+bag.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import UIKit
import ReactiveSwift

/// 给对象增加一个dict用来存储disposable, 可以自己持有disposable
protocol DisposeProtocol: AnyObject {
    func resetDisposeBag()
    func resetDisposableWithTag(_ tag: String)
    func setDisposable(_ tagName: String, _ disposable: Disposable?)
    func getDisposable(_ tagName: String) -> Disposable?
    // 禁止外部访问disposeBag 防止外部调用disposeBag["xxx"] = xxx 导致原有的disposable不执行dispose()
//    var disposeBag: [String : Disposable]
}

private var psdDisposeBagKey: UInt8 = 0
extension DisposeProtocol {
    private var disposeBag: [String: Disposable] {
        get {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            if let bag = objc_getAssociatedObject(self, &psdDisposeBagKey) as? [String: Disposable] {
                return bag
            } else {
                let bag: [String: Disposable] = [:]
                objc_setAssociatedObject(self, &psdDisposeBagKey, [:], .OBJC_ASSOCIATION_RETAIN)
                return bag
            }
        }
        set {
            objc_setAssociatedObject(self, &psdDisposeBagKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    func resetDisposeBag() {
        self.disposeBag.values.forEach { $0.dispose() }
        self.disposeBag = [:]
    }
    func resetDisposableWithTag(_ tag: String) {
        self.disposeBag[tag]?.dispose()
        self.disposeBag[tag] = nil
    }
    
    func setDisposable(_ tagName: String, _ disposable: Disposable?) {
        if let bag = self.disposeBag[tagName] {
            bag.dispose()
            self.disposeBag[tagName] = nil
        }
        self.disposeBag[tagName] = disposable
    }
    
    func getDisposable(_ tagName: String) -> Disposable? {
        if let bag = self.disposeBag[tagName] {
            return bag
        } else {
            return nil
        }
    }
}
extension NSObject: DisposeProtocol {}

public extension Disposable {
    /// 外部基本只会调用这个方法, DisposeProtocol的方法基本不会去调用
    func disposeBag(_ target: NSObject?, tag: String) {
        guard let target = target else { return }
        target.setDisposable(tag, self)
    }
}
