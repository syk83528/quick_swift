//
//  UserManager.swift
//  spsd
//
//  Created by Kevin on 2020/5/20.
//  Copyright © 2020 未来. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import MMKV

class UserManager {
    private init() { }
    static var to = UserManager()
    private var _loginer: User = User()
    
    static var isLogin: Bool {
        to._loginer.userId > 0
    }
    
    static var current: User? {
        isLogin ? to._loginer : nil
    }
    
    static var isBetaUser: Bool {
        false
    }
    
    // MARK: - action
    static func logout() {
        to._loginer = User()
    }
}
