//
//  Env.swift
//  spsd
//
//  Created by Wildog on 12/5/19.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import HandyJSON
import MMKV
import CryptoSwift
import common

extension AES {
    convenience init?(keyString: String) {
        do {
            try self.init(key: Array(keyString.utf8), blockMode: ECB(), padding: .pkcs5)
        } catch {
            return nil
        }
    }
}

class EnvAPNS: HandyJSON, Equatable {
    
    var appId: String
    var appKey: String
    var appSecret: String
    
    /// 朵蜜
    static let prod = EnvAPNS(
        appId: "GnCgOh0Scp9ofEirFeFlu2",
        appKey: "RcGqpwjHpS7CIWItn3xGT7",
        appSecret: "bCnWrDLef6AedYEAvusHl7"
    )
    
    /// 朵蜜Develop
    static let test = EnvAPNS(
        appId: "kffoePzZ0x71o7XckPRQc1",
        appKey: "RQbZMKTb3EA13l48mqebj9",
        appSecret: "GX9KUV4fRsArawgHEBdZf2"
    )
    
    required init() {
        appId = ""
        appKey = ""
        appSecret = ""
    }
    
    init(appId: String, appKey: String, appSecret: String) {
        self.appId = appId
        self.appKey = appKey
        self.appSecret = appSecret
    }
    
    static func == (lhs: EnvAPNS, rhs: EnvAPNS) -> Bool {
        lhs.appId == rhs.appId && lhs.appKey == rhs.appKey && lhs.appSecret == rhs.appSecret
    }
}

class EnvConstants: CustomStringConvertible, HandyJSON, Equatable {
    
    var baseUrl: String
    var apns: EnvAPNS
    var key: String
    var device = "ios"
    var cdn: String
    var bucket: String
    var videoBucket: String
    var bucketPasscode: String
    var bucketOperator: String
    
    private(set) var cipher: Cipher?
    var isUserDefined: Bool
    
    required init() {
        baseUrl = ""
        apns = EnvAPNS.prod
        key = ""
        cdn = ""
        isUserDefined = false
        
        bucket = "psdfile"
        /// videoBucket 没有这个桶
        videoBucket = "psdvideo"
        bucketPasscode = "psd123456"
        bucketOperator = "public"
    }
    
    init(baseUrl: String, key: String, cdn: String, apns: EnvAPNS = EnvAPNS.prod, bucket: String = "psdfile", videoBucket: String = "psdvideo", bucketPasscode: String = "psd123456", bucketOperator: String = "public", custom: Bool = false) {
        self.baseUrl = baseUrl
        self.apns = apns
        self.key = key
        self.cdn = cdn
        self.isUserDefined = custom
        
        self.bucket = bucket
        self.videoBucket = videoBucket
        self.bucketPasscode = bucketPasscode
        self.bucketOperator = bucketOperator
    }
    
    var description: String {
        self.toJSONString() ?? ""
    }
    
    static func == (lhs: EnvConstants, rhs: EnvConstants) -> Bool {
        lhs.baseUrl == rhs.baseUrl
            && lhs.apns == rhs.apns
            && lhs.key == rhs.key
            && lhs.cdn == rhs.cdn
            && lhs.device == rhs.device
            && lhs.bucket == rhs.bucket
            && lhs.videoBucket == rhs.videoBucket
            && lhs.bucketPasscode == rhs.bucketPasscode
            && lhs.bucketOperator == rhs.bucketOperator
    }
}

extension KVStoreKeys {
    fileprivate static let currentEnv = KVStoreKey<Dict>("Env.current.v1")
}

enum Env: Equatable, CaseIterable {
    case mock(_ constants: EnvConstants = Env.defaultMockConstants)
    case custom(_ constants: EnvConstants = Env.defaultCustomConstants)
    case dev(_ constants: EnvConstants = Env.defaultDevConstants)
    case test(_ constants: EnvConstants = Env.defaultTestContants)
    case local(_ constants: EnvConstants = Env.defaultLocalContants)
    case preTest(_ constants: EnvConstants = Env.defaultPreTestContants)
    case prod(_ constants: EnvConstants = Env.defaultProdConstants)
    
    static func == (lhs: Env, rhs: Env) -> Bool {
        switch (lhs, rhs) {
            case let (.mock(l), .mock(r)),
                 let (.dev(l), .dev(r)),
                 let (.custom(l), .custom(r)),
                 let (.test(l), .test(r)),
                 let (.local(l), .local(r)),
                 let (.preTest(l), .preTest(r)),
                 let (.prod(l), .prod(r)):
                return l == r
            default:
                return false
        }
    }
    
    static var allCases: [Env] {
        [.mock(), .custom(), .dev(), .test(), .local(), .preTest(), .prod()]
    }
    
    func toJSON() -> Dict {
        var dict = ["env": caseName] as Dict
        if constants.isUserDefined, let values = constants.toJSON() {
            dict["constants"] = values
        }
        return dict
    }
}

extension Env {
    
    static let defaultCustomConstants = EnvConstants(
        baseUrl: "http://192.168.8.108:8080/api",
        key: "psd4c45gw8er7a5s",
        cdn: "https://file.nidong.com",
        apns: .test
    )
    
    static let defaultMockConstants = EnvConstants(
        baseUrl: "http://mock.psdpp.com/api",
        key: "psd4c45gw8er7a5s",
        cdn: "https://file.nidong.com",
        apns: .test
    )
    
    static let defaultDevConstants = EnvConstants(
        baseUrl: "http://apidev.psdpp.com/api",
        key: "psd4c45gw8er7a5s",
        cdn: "https://file.nidong.com",
        apns: .test
    )
    
    static let defaultTestContants = EnvConstants(
        baseUrl: "http://apitest.psdpp.com/api",
        key: "psd4c45gw8er7a5s",
        cdn: "https://file.nidong.com",
        apns: .test
    )
    
    static let defaultLocalContants = EnvConstants(
        baseUrl: "http://192.168.8.108:8080/api",
        key: "psd4c45gw8er7a5s",
        cdn: "https://file.nidong.com",
        apns: .test
    )
    
    static let defaultPreTestContants = EnvConstants(
        // 预发host  预发
        baseUrl: "https://testapi.ipsdapp.com/api",
        key: "psd4c98gw8Kr1a6s",
        cdn: "https://file.nidong.com",
        apns: .prod
    )
    
    static let defaultProdConstants = EnvConstants(
        baseUrl: "https://api.ipsdapp.com/api",
        key: "psd4c98gw8Kr1a6s",
        cdn: "https://file.nidong.com",
        apns: .prod
    )
    
    private static var __current: Self?
    static var current: Self {
        get {
            if let currentEnv = __current {
                return currentEnv
            }
            #if DEBUG || TEST || ENVS
            if let dict = KVStore[.currentEnv] {
                let env = dict["env"].string, constants = dict["constants"].dictionary
                #if DEBUG
                __current = Self(env: env ?? "dev",
                                 constants: constants != nil ? EnvConstants.deserialize(from: constants) : nil)
                #else
                __current = Self(env: env ?? "test",
                                 constants: constants != nil ? EnvConstants.deserialize(from: constants) : nil)
                #endif
            } else {
                __current = .test()
            }
            return __current ?? .test()
            #else
            return .prod()
            #endif
        }
        set {
            __current = newValue
            #if DEBUG || TEST || ENVS
            KVStore[.currentEnv] = newValue.toJSON()
            #endif
        }
    }
    
    var title: String {
        switch self {
            case .custom:
                return "自定义环境"
            case .mock:
                return "开发/Mock"
            case .dev:
                return "开发环境"
            case .test:
                return "测试环境"
            case .local:
                return "本地环境"
            case .preTest:
                return "预发环境"
            case .prod:
                return "生产环境"
        }
    }
    
    var needsRestart: Bool {
        switch self {
            case .prod:
                return true
            default:
                return false
        }
    }
    
    var needsLogout: Bool {
        switch self {
            case .prod, .dev, .mock, .preTest, .test, .custom:
                return true
            default:
                return false
        }
    }
    
    var isLocalCustom: Bool {
        switch self {
        case .local, .custom:
            return true
        default:
            return false
        }
    }
    
    var constants: EnvConstants {
        switch self {
            case let .custom(constants),
                 let .mock(constants),
                 let .dev(constants),
                 let .test(constants),
                 let .local(constants),
                 let .preTest(constants),
                 let .prod(constants):
                return constants
        }
    }
    
    init(env: String?, constants: EnvConstants?) {
        switch env {
            case "custom":
                self = .custom(constants ?? Env.defaultCustomConstants)
            case "mock":
                self = .mock(constants ?? Env.defaultMockConstants)
            case "dev":
                self = .dev(constants ?? Env.defaultDevConstants)
            case "test":
                self = .test(constants ?? Env.defaultTestContants)
            case "local":
                self = .local(constants ?? Env.defaultLocalContants)
            case "preTest":
                self = .preTest(constants ?? Env.defaultPreTestContants)
            case "prod":
                self = .prod(constants ?? Env.defaultProdConstants)
            default:
                self = .prod()
        }
    }
    
    var caseName: String {
        switch self {
            case .custom:
                return "custom"
            case .mock:
                return "mock"
            case .dev:
                return "dev"
            case .test:
                return "test"
            case .local:
                return "local"
            case .preTest:
                return "preTest"
            case .prod:
                return "prod"
        }
    }
    
    var description: String {
        "[\(caseName)]: \(constants)"
    }
    
}
