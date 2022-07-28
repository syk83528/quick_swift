//
//  MainViewController.swift
//  quick
//
//  Created by suyikun on 2021/6/21.
//

import Foundation
import common

class MainViewController: UITabBarController {
    lazy var tabProviders: [TabProvider] = [
        home
    ]
    
    let home = HomeVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        tabBar.isTranslucent = false
        tabBar.tintColor = .hex(0x741EFF)
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.clipsToBounds = false
        tabBar.layer.shadowOffset = MakeSize(0, -1)
        tabBar.layer.shadowRadius = 3
        tabBar.layer.shadowColor = UIColor.hex(0xbdbdbd).alpha(0.5).cgColor
        tabBar.layer.shadowOpacity = 1.0
        
        setupViewControllers()
        
        r.signal(for: #selector(viewDidAppear(_:))).take(first: 1).take(during: self.r.lifetime).observeValues { [weak self] (_) in
            guard let self = self else { return }
            self.fixShadowImage()
        }
    }
    
    func setupViewControllers() {
//        for (_, tabProvider) in tabProviders.enumerated() {
//            let item = tabProvider.tabBarItem
//            let controller = tabProvider.controller
//            controller.tabBarItem = item
//        }
        home.tabBarItem = (home as TabProvider).tabBarItem
//
//        let controllers = tabProviders.compactMap { $0.controller }
        self.viewControllers = [home]
//        setViewControllers([home], animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        llog("💀💀💀------------ \(Self.self)")
    }
}

extension MainViewController {
    func fixShadowImage() {
        if #available(iOS 13.0, *) {
            let appearance = tabBar.standardAppearance
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
        } else {
            // Fallback on earlier versions
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }
    }
}
