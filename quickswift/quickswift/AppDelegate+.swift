//
//  AppDelegate+.swift
//  quick
//
//  Created by suyikun on 2021/6/21.
//

import Foundation
import RTNavigationController

extension SceneDelegate {
    func prepareRootController(firstLaunch: Bool = false) {
        guard let window = self.window else { return }
        
        let vc = RTRootNavigationController(rootViewController: MainViewController())
        _ = DebugHandler.shared
        window.rootViewController = vc
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        return
    }
}
