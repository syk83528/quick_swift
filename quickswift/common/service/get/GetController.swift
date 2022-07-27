//
//  GetController.swift
//  spsd
//
//  Created by suyikun on 2021/12/29.
//  Copyright © 2021 未来. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import ReactiveCocoa

open class GetController: NSObject {
    
    // MARK: - --------------------------------------Property
    /// page页
    public weak var _page: AnyObject?
    public var _identify: String?
    /// 生命周期信号
    public var life: Signal<GetLifeCycle, Never> {
        lifeCycleSignal.output
    }
    /// 生命周期信号
    private let lifeCycleSignal = Signal<GetLifeCycle, Never>.pipe()
    
    /// 是否打印声明周期
    open var logLifecycle: Bool {
        false
    }
    // MARK: - --------------------------------------initial
    
    public init(_ page: AnyObject? = nil, identify: String? = nil) {
        super.init()
        self._page = page
        self._identify = identify
        // controller才能触发
        if let page = page as? UIViewController {
            //        let viewWillAppear = #selector(UIViewController.viewWillAppear(_:))
            page.r.trigger(for: #selector(UIViewController.viewDidLoad)).observeValues {[weak self] _ in
                self?.lifeCycleSignal.input.send(value: .viewDidLoad)
                self?.onViewDidLoad()
            }
            page.r.trigger(for: #selector(UIViewController.viewWillAppear(_:))).observeValues {[weak self] _ in
                self?.lifeCycleSignal.input.send(value: .viewWillAppear)
                self?.onViewWillAppear()
            }
            page.r.trigger(for: #selector(UIViewController.viewDidAppear(_:))).observeValues {[weak self] _ in
                self?.lifeCycleSignal.input.send(value: .viewDidAppear)
                self?.onViewDidAppear()
            }
            page.r.trigger(for: #selector(UIViewController.viewWillDisappear(_:))).observeValues {[weak self] _ in
                self?.lifeCycleSignal.input.send(value: .viewWillDisappear)
                self?.onViewWillDisappear()
            }
            page.r.trigger(for: #selector(UIViewController.viewDidDisappear(_:))).observeValues {[weak self] _ in
                self?.lifeCycleSignal.input.send(value: .viewDidDisappear)
                self?.onViewDidDisappear()
            }
        }
        onInit()
    }
    
    // MARK: - --------------------------------------LifeCycle
    /// 均会触发
    open func onInit() {
        if logLifecycle { getllog("\(Self.className)\(_identify == nil ? "":"__identify:\(_identify!)")__\(#function)}") }
    }
    
    /// 仅 UIViewController 的管理器触发
    open func onViewDidLoad() {
        if logLifecycle { getllog("\(Self.className)\(_identify == nil ? "":"__identify:\(_identify!)")__\(#function)}") }
    }
    /// 仅 UIViewController 的管理器触发
    open func onViewWillAppear() {
        if logLifecycle { getllog("\(Self.className)\(_identify == nil ? "":"__identify:\(_identify!)")__\(#function)}") }
    }
    /// 仅 UIViewController 的管理器触发
    open func onViewDidAppear() {
        if logLifecycle { getllog("\(Self.className)\(_identify == nil ? "":"__identify:\(_identify!)")__\(#function)}") }
    }
    /// 仅 UIViewController 的管理器触发
    open func onViewWillDisappear() {
        if logLifecycle { getllog("\(Self.className)\(_identify == nil ? "":"__identify:\(_identify!)")__\(#function)}") }
    }
    /// 仅 UIViewController 的管理器触发
    open func onViewDidDisappear() {
        if logLifecycle { getllog("\(Self.className)\(_identify == nil ? "":"__identify:\(_identify!)")__\(#function)}") }
    }
    /// 均会触发
    open func onDispose() {
        if logLifecycle { getllog("\(Self.className)\(_identify == nil ? "":"__identify:\(_identify!)")__\(#function)}") }
    }
    
    deinit {
        onDispose()
    }
}
