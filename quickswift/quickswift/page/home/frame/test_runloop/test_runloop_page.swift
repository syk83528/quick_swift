//
//  test_runloop_page.swift
//  quickswift
//
//  Created by suyikun on 2022/8/1.
//

import Foundation
import UIKit
import common

class TestRunloopPage: BaseGetPage, TableProvider {
    typealias DataType = TestRunloopModel
    
    lazy var c: TestRunloopGetController! = TestRunloopGetController(self)
    
    override func commonInit() {
        super.commonInit()
        Get.put(c)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "测试"
        _configTable()
        
        startButton.add(to: view)
        endButton.add(to: view)
        btnClear.add(to: view)
        
        
        startButton.r.touchUpInside.observeValues { [weak self] _ in
            guard let self = self else { return }
            self.c.startCellAdd()
        }
        
        endButton.r.touchUpInside.observeValues { [weak self] _ in
            guard let self = self else { return }
            self.c.endCellAdd()
        }
        
        btnClear.r.touchUpInside.observeValues { [weak self] _ in
            guard let self = self else { return }
            self.c.clearCell()
        }
    }
     
    func _configTable() {
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
                tableView.sectionHeaderTopPadding = 0;
            } else {
                // Fallback on earlier versions
            }
        tableViewController.moveTo(self)
        tableView.register(cell: TestRunloopCell.self, for: TestRunloopModel.self)
//        tableViewController.selectCell.observeValues {[weak self] model in
//            guard self != nil else { return }
////            (model.T as? UIViewController.Type)?.push()
//        }
//        list = items
//        list = [
//            TestRunloopModel(name: "222"),
//            TestRunloopModel(name: "222"),
//            TestRunloopModel(name: "222"),
//            TestRunloopModel(name: "222"),
//            TestRunloopModel(name: "222"),
//            TestRunloopModel(name: "222"),
//            TestRunloopModel(name: "222"),
//            TestRunloopModel(name: "222"),
//        ]
//        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.pin.top().left( ).right(100).height(200)
        
        startButton.pin.top(40).width(80).right(10).height(50)
        endButton.pin.top(to: startButton.edge.bottom).marginTop(20).width(80).right(10).height(50)
        btnClear.pin.top(to: endButton.edge.bottom).marginTop(20).width(80).right(10).height(50)
    }
    
    // MARK: - --------------------------ui
    private let startButton = UIButton().then {
        $0.setTitle("开始", for: .normal)
        $0.backgroundColor = .randomWithLight
        $0.layer.cornerRadius = 8
    }
    private let endButton = UIButton().then {
        $0.setTitle("结束", for: .normal)
        $0.backgroundColor = .randomWithLight
        $0.layer.cornerRadius = 8
    }
    private let btnClear = UIButton().then {
        $0.setTitle("清空", for: .normal)
        $0.backgroundColor = .randomWithLight
        $0.layer.cornerRadius = 8
    }
}
