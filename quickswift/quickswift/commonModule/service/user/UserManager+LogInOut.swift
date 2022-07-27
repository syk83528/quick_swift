//
//  UserManager+LogInOut.swift
//  spsd
//
//  Created by Kevin on 2020/5/20.
//  Copyright © 2020 未来. All rights reserved.
//

import UIKit

extension UserManager {
    
    /// 收到登录成功的回调后
//    func loginSuccessed(user: User, withFirstLaunch isFirstLaunch: Bool = false) {
//        User.clear()
//        user.save()
//
//        Notif.User.didLogin.post()
//        /// 查询贵族等级，消息页用到的隐身相关/背包礼物、道具
//        UserManager.requestUserInfo(user.userId, options: [.basic, .stat, .giftProp], behaviors: [.hideActivityIndicator, .suppressMessage()]).start()
//
//        AppDelegate.shared.prepareRootController(firstLaunch: isFirstLaunch)
//        IAPHelper.shared.loadOwnOrders()
//
//        /// 存储 additional
//        UserManager.getUserAdditional(userId: user.userId).start()
//        // initial realm
//        UserAppDelegate.shared.setupRealm()
//
//        UserAppDelegate.shared.updateGeneralResources(force: true)
//    }
//
//    func logout(_ completion: (() -> Void)? = nil) {
//        defer {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                User.clear()
//                AppDelegate.shared.prepareRootController()
//                #if DEBUG || TEST
//                DebugSocketManager.shared.disconnect()
//                #endif
//            }
//        }
//        let userId = UserManager.current?.userId
//        // 角标清空
//        MainAppDelegate.shared.notificationHandler.update(badge: 0)
//
//        // 退出登录时候，结束小窗
//        LiveManager.shared.quitLive()
//        CallManager.quitCall()
//        CallManager.endAutoCall(true, force: true)
//
//        if UserManager.current != nil {
//            LoginAPI.shared.make(.logout, behaviors: [.suppressMessage(), .hideActivityIndicator]).start()
//        }
//        Notif.User.didLogout.post(object: userId)
//        AppManager.Realm.reloadedValue = false // reset to false
//        completion?()
//    }
}
