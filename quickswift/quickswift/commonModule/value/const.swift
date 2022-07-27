//
//  const.swift
//  quickswift
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import UIKit

struct Const {
    private init() { }
    
    static let appType = 17 // 弹豆 p6.5.0
    static let platformType = 1 // 平台类型 安卓0，iOS:1
    static let umengAppKey = "54182679fd98c579a8013290"
    static let smOrganization = "So1nBokzhULimuYXN1ud"
    static let source = "AppStore"
    static let project = "taoqu."
    static let appName = "朵蜜"
    static let universalLinks = "https://duomi.duixiangqin.com/"
    #if DEBUG || TEST
    static let appChannel = "Test Duomi"
    #else
    static let appChannel = "App Store Duomi"
    #endif
    /// horizontal margin
    static let hMargin: CGFloat = 16.0
    
    // https://apps.apple.com/cn/app/id1485501092
    static let appStoreId = "1485501092"
    
    static let coinUnit = "金币"
    static let beanUnit = "金豆"
    static let rmbUnit = "元"
    static let rewardBeanUnit = " 奖励金豆"
    static let company = "重庆滔趣网络科技有限公司"
    static let main = "小蜜蜂"
    ///蜜友
    static let friend = "蜜友"
    /// 公众号
    static let officialAccounts = "朵蜜APP"
    
    static let replacing = "盘丝洞"
    
    static let trackerKey = "psd@2021!psd"
}

extension Const {
    struct WeiboConfig {
        private init() { }
        
        static let key = "3697301990"
    }
    struct CLDetect {
        private init() { }
        // static let appid = "bxLCJLJm"
        // static let appkey = "p8qUhfS1"
        static let appKey = "WGg6Q19m9810H4i4"
        static let appSecret = "x6gXj8C0PuKx1ENT"
    }
    
    struct MapConfig {
        private init() { }
        
        static let key = "6e27c8775df5f40376bc5c49cf1f34bc"
    }
    
    struct AgoraConfig {
        private init() { }
        
        // junfly: c78e65f52f0f4e368ebb05c36639f3a5
        static let id = "ddc4026604fb416fa99095e757d9f429"
    }
    
    struct QQConfig {
        private init() { }
        
        static let key = "101895818"
    }
    
    struct WXConfig {
        private init() { }
        
        static let id = "wx51b1d7857848b544"
    }
    
    struct CLSYConfig {
        private init() { }
        
        static let id = "WMKu2TJt"
        static let key = "rVaRjEQ6"
    }
    
//    struct GeTuiConfig {
//        private init() {}
//        // 在ENV中设置的
//        static let id: "GnCgOh0Scp9ofEirFeFlu2"
//        static let key: "RcGqpwjHpS7CIWItn3xGT7"
//        static let secret: "bCnWrDLef6AedYEAvusHl7"
//    }
    
    struct BuglyConfig {
        private init() {}
        
        static let id = "de57b27dfc"
    }
    
    struct SmConfig {
        private init() {}
        
        static let organization = "So1nBokzhULimuYXN1ud"
        static let appID = "default"
        static let publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCYVG5aAzjOMxkp8BCTQNwJpqFHx2z7ab/ziA0S0Vj8wKQdfwUDsfcLJwlv96PW6V1qtgwJ7c0W9jWIRYsabRd6xpEMXgFzRQzZrk5rFIQmtj7bgjzBk+KRdp8CxCmxYbo69E8OF6Rd2N0cZL9gFlirs4Dk4Wa+ohOU0mNqb8hUPwIDAQAB"
    }
    
    // MARK: - Neteasy
    struct NetEasy {
        private init() { }
        
        static let liveDetectBusinessID = "37d817cd3340490e9c32a45537234312"
        static let ocrBusinessID = "49906f9baf784c34933a76569ab4912b"
    }
}

