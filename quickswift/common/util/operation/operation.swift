//
//  operation.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import ReactiveSwift

public protocol MyCancelableBlockProtocol {
    func complete()
}


public class MyCancelableBlockOperation: Operation, MyCancelableBlockProtocol {
    // MARK: - --------------------------------------info
    private var autoCancelTimeout: TimeInterval?
    
    private var blockTimeout: TimeInterval?
    
    private var block: ((MyCancelableBlockProtocol) -> Void)?
    
    private var _isExecuting: Bool = false
    public override var isExecuting: Bool {
        return _isExecuting
    }
    
    private var _isFinished: Bool = false
    public override var isFinished: Bool {
        return _isFinished
    }
    // MARK: - --------------------------------------system
    public init(autoCancelTimeout: TimeInterval? = nil, blockTimeout: TimeInterval? = nil,  _ block: @escaping (MyCancelableBlockProtocol) -> Void) {
        self.block = block
        self.autoCancelTimeout = autoCancelTimeout
        self.blockTimeout = blockTimeout
        super.init()
        
        if let autoCancelTimeout = self.autoCancelTimeout {
            DispatchQueue.global().asyncAfter(deadline: .now() + autoCancelTimeout, execute: { [ weak self] in
                guard let self = self,
                      self.isReady,
                      !self.isFinished
                else { return }
                getllog("取消了")
                self.cancel()
            })
        }
    }

    public override func start() {
        // 先判断当前Operation是否已经取消，如果取消则不再执行任务，并将状态设置为finished为true
        if isCancelled {
            willChangeValue(forKey: "isFinished")
            _isFinished = true
            didChangeValue(forKey: "isFinished")
            return
        }
        
        guard let block = block else {
            complete()
            return
        }
        if isCancelled {
            complete()
            return
        }
        
        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        didChangeValue(forKey: "isExecuting")
        
        block(self)
        if let blockTimeout = self.blockTimeout {
            DispatchQueue.global().asyncAfter(deadline: .now() + blockTimeout, execute: { [ weak self] in
                guard let self = self,
                      self.isReady,
                      !self.isFinished
                else { return }
                self.complete()
            })
        }
    }
    
    public func complete() {
//        super.start()
        willChangeValue(forKey: "isFinished")
        willChangeValue(forKey: "isExecuting")
        _isExecuting = false
        _isFinished = true
        didChangeValue(forKey: "isFinished")
        didChangeValue(forKey: "isExecuting")
    }
    
    public override func cancel() {
        if isExecuting {
            complete()
        } else {
            super.cancel()
        }
    }
    
    deinit {
        #if DEBUG || ENVS
        print("~MyCancelableBlockOperation销毁了")
        #endif
    }
}
