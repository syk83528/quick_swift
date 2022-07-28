//
//  HomeVC.swift
//  quickswift
//
//  Created by suyikun on 2022/7/28.
//

import Foundation

class HomeVC: BasePage {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .orange
    }
}

extension HomeVC: TabProvider {
    var tabIdentifier: String {
        "home"
    }
    
    var tabTitle: String {
        "首页"
    }
    
    var tabImageName: String {
        "tab_discover"
    }
    
    var controller: UIViewController {
        self
    }
    
}
