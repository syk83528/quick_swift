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
        
        #if targetEnvironment(simulator)
        // 神器: https://github.com/johnno1962/InjectionIII
        // 下载地址: https://github.com/johnno1962/InjectionIII/releases
        // 该 app 在 mac App Store 上架，但是还没有更新到适配 big sur. big sur 适配需要去上面的地址下载.
        // 模拟器热更新，仅在模拟器时有效, 修改代码后 Command+S 保存即可热更新
        // 说明:
        // 默认情况下重新编译完成后需要返回再进入（需要触发 viewDidLoad)
        // 如需要实时更新且不触发 viewDidLoad 自己实现一个 @objc func injected() {} 把需要热更新的内容丢到里面即可
        // ‼️重要:
        // 项目不能放在 Desktop(桌面) 和 Documents(文稿) 中, InjectionIII 会有权限问题导致不会工作
//        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif
        
        let vc = RTRootNavigationController(rootViewController: MainViewController())
        _ = DebugHandler.shared
        window.rootViewController = vc
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        
        return
    }
}
