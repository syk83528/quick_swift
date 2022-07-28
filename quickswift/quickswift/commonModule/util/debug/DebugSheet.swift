//
//  DebugSheet.swift
//  quick
//
//  Created by suyikun on 2021/5/6.
//

import Foundation
import YYText

#if DEBUG || ENVS
struct DebugSheet {
    
    private static let shared = DebugSheet()
    private init() {}
    
    func items() -> [UIAlertAction] {
        [
            UIAlertAction(title: "UI", style: .default, handler: { (_) in
                UIAlertController.show(DebugSheet.shared.ui())
            }),
            UIAlertAction(title: "取消", style: .cancel)
        ]
    }
    
    static func show() {
        UIAlertController.show(shared.items())
    }
}

extension DebugSheet {
    func ui() -> [UIAlertAction] {
        [
            UIAlertAction(title: "black", style: .default, handler: { (_) in
//                AppDelegate.shared.window?.changeSaturate(true)
            }),
            UIAlertAction(title: "white", style: .default, handler: { (_) in
//                AppDelegate.shared.window?.changeSaturate(false)
            })
        ]
    }
}
#endif
