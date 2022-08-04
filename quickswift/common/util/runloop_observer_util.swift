//
//  runloop_observer_util.swift
//  quickswift
//
//  Created by suyikun on 2022/8/2.
//

import Foundation
public enum RunloopObserverType {
    case main
    case current
}
public enum RunloopObserverMode {
    case defaultMode
    case commonModes
}
public final class RunloopObserverUtil: NSObject {
    public init(
        type: RunloopObserverType = .main,
        mode: RunloopObserverMode = .defaultMode
    ) {
        self.type = type
        self.mode = mode
    }
    
    // MARK: - --------------------------info
    private var _loop: CFRunLoop {
        type == .main ? CFRunLoopGetMain() : CFRunLoopGetCurrent()
    }
    
    private var _mode: CFRunLoopMode {
        mode == .defaultMode ? .defaultMode : .commonModes
    }
    
    private var type: RunloopObserverType
    private var mode: RunloopObserverMode
    
    private var o: CFRunLoopObserver?
    
    private var _lockArr: NSLock = NSLock()
    private var _taskArr: [() -> ()] = []
    
    private var taskArr: [() -> ()] {
        get {
            _lockArr.lock()
            let v = _taskArr
            _lockArr.unlock()
            return v
        }
        set {
            _lockArr.lock()
            _taskArr = newValue
            _lockArr.unlock()
        }
    }
    
    // MARK: - --------------------------action
    /// handler会在进入睡眠时多次调用
    public func addRunloopWaitTask(_ handler: @escaping () -> ()) {
        taskArr.append(handler)
    }
    
    public func startObserver() {
        if (o != nil) {
            CFRunLoopRemoveObserver(_loop, o, _mode)
            o = nil
        }
        
        o = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, true, 0, { [weak self] (_, _) in
            guard let self = self,
                  self.taskArr.count > 0
            else {
                return
            }
            let block = self.taskArr.removeFirst()
//            self.performSelector(onMainThread: #selector(Self._doTaskHandler(_:)), with: block, waitUntilDone: false, modes: [String(CFRunLoopMode.defaultMode.rawValue)])
//            self.perform(#selector(Self._doTaskHandler(_:)), on: Thread.main, with: block, waitUntilDone: false, modes: [String(CFRunLoopMode.defaultMode.rawValue)])
            block()
        })
        CFRunLoopAddObserver(_loop, o!, _mode)
    }
    
    
    public func endObserver() {
        if (o != nil) {
            #if DEBUG || TEST || BETA
            print("runloop 被释放")
            #endif
            CFRunLoopRemoveObserver(_loop, o, _mode)
            o = nil
        }
    }
    
//    @objc func _doTaskHandler(_ block: @escaping () -> ()) {
//        block()
//    }
    
    deinit {
        taskArr.removeAll()
        
        if (o != nil) {
            #if DEBUG || TEST || BETA
            print("runloop 被释放")
            #endif
            CFRunLoopRemoveObserver(_loop, o, _mode)
            o = nil
        }
    }
}
