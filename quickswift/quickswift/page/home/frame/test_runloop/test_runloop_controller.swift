//
//  test_runloop_controller.swift
//  quickswift
//
//  Created by suyikun on 2022/8/2.
//

import Foundation
import common
import ReactiveSwift

class TestRunloopGetController: GetController {
    
    override var logLifecycle: Bool {
        true
    }
    // MARK: - --------------------------info
    var msgRunloop = RunloopObserverUtil(type: .main, mode: .defaultMode)
    
    var page: TestRunloopPage? { self._page as? TestRunloopPage }
    
    var index: Int = 0
    
    var cellAddTimer: Disposable?
    // MARK: - --------------------------system
    override func onViewDidLoad() {
        super.onViewDidLoad()
        msgRunloop.startObserver()
    }
    // MARK: - --------------------------action
    func startCellAdd() {
        cellAddTimer?.dispose()
        cellAddTimer = SignalProducer.timer(interval: .milliseconds(1000), on: QueueScheduler.main).take(duringLifetimeOf: self).startWithSuccess({ [weak self] _ in
            guard let self = self else { return }
            self.index += 1
            let index = self.index
            print("添加了任务")
            self.msgRunloop.addRunloopWaitTask { [weak self] in
                let m = TestRunloopModel(name: "这是第\(index)个cell")
                DispatchQueue.global().async {
                    self?.page?.list.append(m)
                    DispatchQueue.main.async {
                        self?.page?.tableView.reloadData()
                        self?.page?.tableView.scrollToBottom(triggerByUser: false)
                    }
                }
            }
        })
    }
    
    func endCellAdd() {
        cellAddTimer?.dispose()
    }
    
    func clearCell() {
        index = 0
        self.page?.list = []
        self.page?.tableView.reloadData()
    }
}
