//
//  MainAppDelegate.swift
//  quick
//
//  Created by suyikun on 2021/6/21.
//

import Foundation
extension Notif {
    struct App {
        static let keyboardWillChangeFrame = Notif("App.keyboardWillChangeFrame")
        /// app 系统时间修改通知
        static let significantTimeChangeNotification = Notif("App.significantTimeChangeNotification")
    }
}
class MainAppDelegate: NSObject, UIApplicationDelegate {
    static let shared: MainAppDelegate = MainAppDelegate()
    private override init() {}
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        _ = DebugHandler.shared
        
        return true
    }
}


extension MainAppDelegate: RootProviderProtocol {
    func provide(for window: UIWindow, firstLaunch: Bool) -> Bool {
        guard let _ = User.loginer else { return false }
        
        window.rootViewController = RTRootNavigationController(rootViewController: MainViewController())
        window.makeKeyAndVisible()
        return true
    }
}
