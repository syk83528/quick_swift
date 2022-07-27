//
//  windowlevel.swift
//  quickswift
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import UIKit

public extension UIWindow.Level {
    
    private static var statusBarRawValue: CGFloat { return UIWindow.Level.statusBar.rawValue }
    
    static var live: UIWindow.Level {
        .init(Self.statusBarRawValue - 12)
    }
    static var chat: UIWindow.Level {
        .init(Self.statusBarRawValue - 9)
    }
    /// 匹配(声音速配, 视频速配（畅聊）等)
    static var match: UIWindow.Level {
        .init(Self.statusBarRawValue - 1)
    }
    static var debugLog: UIWindow.Level {
        .init(Self.statusBarRawValue + 2)
    }
    static var logo: UIWindow.Level {
        .init(Self.statusBarRawValue + 3)
    }
    static var newcomerHongbao: UIWindow.Level {
        .init(Self.statusBarRawValue + 4)
    }
    static var dedicatedKeyboard: UIWindow.Level {
        .init(Self.statusBarRawValue + 6)
    }
    static var liveRedpacket: UIWindow.Level {
        .init(Self.statusBarRawValue + 7)
    }
    static var inviteFreeCall: UIWindow.Level {
        .init(Self.statusBarRawValue + 8)
    }
    static var present: UIWindow.Level {
        .init(Self.statusBarRawValue + 19)
    }
    static var overlay: UIWindow.Level {
        .init(Self.statusBarRawValue + 20)
    }
    static var giftDisplay: UIWindow.Level {
        .init(Self.statusBarRawValue + 21)
    }
    static var inAppNotify: UIWindow.Level {
        .init(Self.statusBarRawValue + 23)
    }
    static var sayHi: UIWindow.Level {
        .init(Self.statusBarRawValue + 24)
    }
    static var chatBar: UIWindow.Level {
        .init(Self.statusBarRawValue + 25)
    }
    static var femaleAndMaleNewReward: UIWindow.Level {
        .init(Self.statusBarRawValue + 26)
    }
    static var guide: UIWindow.Level {
        .init(Self.statusBarRawValue + 28)
    }
    static var splash: UIWindow.Level {
        .init(Self.statusBarRawValue + 30)
    }
}
