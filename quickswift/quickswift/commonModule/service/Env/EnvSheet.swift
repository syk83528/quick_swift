//
//  EnvSheet.swift
//  spsd
//
//  Created by Wildog on 3/19/20.
//  Copyright © 2020 Wildog. All rights reserved.
//

import UIKit
import common

extension Notif {
    struct EnvSheet {
        static var doChangeEnv = Notif("EnvSheet.doChangeEnv")
    }
}

struct EnvSheet {
    
    static func show() {
        var items = [ActionSheetItem]()
        
//        var detail = "当前登录用户: \(UserManager.current?.userId ?? "nil"), \(UserManager.current?.nickname ?? "nil")"
//        detail += "\nIM-Chat: \(IMTarget.chat.endPoint), Room: \(IMClient.shared.chatContainer.client.lastJoinedRoom?.name() ?? "nil")"
//        detail += "\nIM-Live: \(IMTarget.party.endPoint), Room: \(IMClient.shared.partyContainer.client.lastJoinedRoom?.name() ?? "nil")"
//        var detail = "当前登录用户: \(UserManager.current?.userId ?? "nil"), \(UserManager.current?.nickname ?? "nil")"
//        detail += "\n 手机号: \(UserManager.current?.phoneNum ?? "nil")"
//        detail = UserManager.current == nil ? "" : detail
//
//        items += ActionSheetItem(headerWithTitle: "开发者设置", subtitle: detail).then {
//            $0.titleFont = .regular(17)
//            $0.titleColor = .lightGray
//            $0.subtitleMaxLines = 8
//            $0.subtitleWidthRatio = 0.85
//        }
//
//        // TODO: custom env
//        let availableEnvs: [Env] = [.test(), .dev(), .custom(), .local(), .preTest(), .prod()]
//        for env in availableEnvs {
//            let constants = env.constants
//            let title = (env == Env.current ? "✔️" : "") + env.title
//            let subtitle = constants.baseUrl
//            items += ActionSheetItem(title: title, subtitle: subtitle) { (_) in
//                EnvSheet.change(env: env)
//            }
//        }
//
//        if UserManager.current?.userId != nil {
//            items += ActionSheetItem(title: "退出登录", action: { (_) in
//                UserManager.shared.logout(nil)
//            })
//        }
//
//        ActionSheet().show(items)
    }
    
    static func change(env: Env) {
//        #if DEBUG || TEST
//        if case .custom = env {
//            let alert: UIAlertController = .init(title: "自定义 API Host", message: "输入自定义的API或IM地址, 均可选, 不填则不修改", preferredStyle: .alert)
//            alert.addTextField { $0.placeholder = "API 格式: http://example.com/api" }
//            alert.addTextField { $0.placeholder = "Chat IM 格式: xxx.xxx.xxx.xxx:xxxxx" }
//            alert.addTextField { $0.placeholder = "Live IM 格式: xxx.xxx.xxx.xxx:xxxxx" }
//            let change = UIAlertAction(title: "我就这么改", style: .destructive, handler: { [weak alert] x in
//                self.changeCustomApi(alert: alert, env: env)
//            })
//            alert.addAction(change)
//            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
//            UIViewController.current?.present(alert, animated: true, completion: nil)
//        } else {
//            self.doNeedsRestart(env: env)
//        }
//        #endif
    }
    
    private static func changeCustomApi(alert: UIAlertController?, env: Env) {
//        guard let tfs = alert?.textFields, tfs.count == 3 else { return }
//        var temp: String = ""
//        if let host = tfs[0].text, host.count > 1, host.hasHttpScheme, host.hasSuffix("/api") {
//            Env.defaultCustomConstants.baseUrl = host
//            temp += " APIHost "
//        }
//        if let chatHost = tfs[1].text, chatHost.count > 1 {
//            let hps = chatHost.split(separator: ":")
//            if hps.count == 2, let host = hps.first, host.count > 7,
//                let portStr = hps[safe: 1], let port = Int(portStr), port > 100 {
//                let chatEndpoint = Env.defaultCustomConstants.defaultChatEndpoint
//                chatEndpoint.host = String(host)
//                chatEndpoint.port = port
//                Env.defaultCustomConstants.defaultChatEndpoint = chatEndpoint
//                temp += " ChatIM "
//                KVStore[KVStoreKeys.IM.chatEndPoint] = [:]
//            }
//        }
//        if let liveHost = tfs[2].text, liveHost.count > 1 {
//            let hps = liveHost.split(separator: ":")
//            if hps.count == 2, let host = hps.first, host.count > 7,
//               let portStr = hps[safe: 1], let port = Int(portStr), port > 100 {
//                let liveEndpoint = Env.defaultCustomConstants.defaultPartyEndpoint
//                liveEndpoint.host = String(host)
//                liveEndpoint.port = port
//                Env.defaultCustomConstants.defaultPartyEndpoint = liveEndpoint
//                temp += " LiveIM "
//                KVStore[KVStoreKeys.IM.partyEndPoint] = [:]
//            }
//        }
//        if temp.count > 0 {
//            Toast("正确修改的有: \(temp)", style: .success).show()
//        } else {
//            Toast("输入正确的 API Host 或 IMEndpoint", style: .fatal).show()
//        }
//        self.doNeedsRestart(env: env)
    }
    
    private static func doNeedsRestart(env: Env) {
//        #if DEBUG || TEST
//        let current = Env.current
//        if current.needsRestart || env.needsRestart {
//            Alert("本次环境切换需要重启应用", title: "提示", confirmTitle: "继续").show(confirmAction: { (_) -> Bool in
//                UserManager.shared.logout({
//                    EnvSheet.doChange(env: env)
//                })
//                return true
//            }, cancelAction: nil, mode: .all)
//        } else if current.needsLogout || env.needsLogout {
//            Alert("本次环境切换需要重新登录", title: "提示", confirmTitle: "继续").show(confirmAction: { (_) -> Bool in
//                UserManager.shared.logout {
//                    EnvSheet.doChange(env: env)
//                }
//                return true
//            }, cancelAction: nil, mode: .all)
//        } else {
//            EnvSheet.doChange(env: env)
//        }
//        #endif
    }
    
    private static func doChange(env: Env) {
//        KVStore[KVStoreKeys.IM.chatEndPoint] = [:]
//        KVStore[KVStoreKeys.IM.partyEndPoint] = [:]
//        Env.current = env
//        Toast("已切换至" + env.title, haptic: .heavy).show()
//        Notif.EnvSheet.doChangeEnv.post()
    }
    
}
