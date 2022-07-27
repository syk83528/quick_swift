//
//  kvstore+.swift
//  quickswift
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import common
import MMKV

extension KVStore {
    static func clearCurrentUser() {
        if let userId = UserManager.current?.userId {
            MMKV(mmapID: "\(userId)")?.clearAll()
            Toast("清除成功").show()
        }
    }
    static func clearAll() {
        MMKV.default()?.clearAll()
        Toast("清除成功").show()
    }
}
