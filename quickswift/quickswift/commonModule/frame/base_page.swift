//
//  base_page.swift
//  quickswift
//
//  Created by suyikun on 2022/7/28.
//

import Foundation
import UIKit
import common

class BasePage: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        llog("\(Self.self)___\(#function)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        llog("\(Self.self)___\(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        llog("\(Self.self)___\(#function)")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        llog("\(Self.self)___\(#function)")
    }
    
    deinit {
        llog("💀💀💀___\(Self.self)")
    }
}

protocol BaseGetPageProtocol {
    associatedtype T: GetController
    var c: T! { get }
}

typealias BaseGetPage = BasePage & BaseGetPageProtocol


//class test_aaaa_page: BaseGetPage {
//
//    var c: TestRunloopGetController! = TestRunloopGetController()
//}
//
//
//class test_bbbb_page: BaseGetPage {
//
//    typealias T = TestRunloopGetController
//
//    var c: TestRunloopGetController!
//
//    override func commonInit() {
//        super.commonInit()
//        c = TestRunloopGetController()
//    }
//}
