//
//  kvstore.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import UIKit
import MMKV

public class KVStoreKey<T>: KVStoreKeys {}

public class KVStoreKeys: RawRepresentable, Hashable {
    public let rawValue: String
    
    required public init!(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public convenience init(_ key: String) {
        self.init(rawValue: key)
    }
    
    public var hashValue: Int {
        rawValue.hashValue
    }
}

public struct KVStore {
    private init() {}
}

public extension KVStore {
    
    static subscript(key: String) -> String? {
        get {
            MMKV.default()?.string(forKey: key)
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV.default()?.removeValue(forKey: key)
                return
            }
            MMKV.default()?.set(value, forKey: key)
        }
    }
    
    static subscript(key: String, userId: String) -> String? {
        get {
            MMKV(mmapID: userId)?.string(forKey: key)
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV(mmapID: userId)?.removeValue(forKey: key)
                return
            }
            MMKV(mmapID: userId)?.set(value, forKey: key)
        }
    }
    
    static subscript(key: KVStoreKey<String>) -> String? {
        get {
            MMKV.default()?.string(forKey: key.rawValue)
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV.default()?.removeValue(forKey: key.rawValue)
                return
            }
            MMKV.default()?.set(value, forKey: key.rawValue)
        }
    }
    
    static subscript(key: KVStoreKey<String>, userId: String) -> String? {
        get {
            MMKV(mmapID: userId)?.string(forKey: key.rawValue)
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV(mmapID: userId)?.removeValue(forKey: key.rawValue)
                return
            }
            MMKV(mmapID: userId)?.set(value, forKey: key.rawValue)
        }
    }
    
    static subscript(key: KVStoreKey<Bool>) -> Bool {
        get {
            MMKV.default()?.bool(forKey: key.rawValue) == true
        }
        set {
            MMKV.default()?.set(newValue, forKey: key.rawValue)
        }
    }
    
    static subscript(key: KVStoreKey<Bool>, default: Bool) -> Bool {
        get {
            MMKV.default()?.bool(forKey: key.rawValue) ?? `default`
        }
        set {
            MMKV.default()?.set(newValue, forKey: key.rawValue)
        }
    }
    
    static subscript(key: KVStoreKey<Bool>, userId: String) -> Bool {
        get {
            MMKV(mmapID: userId)?.bool(forKey: key.rawValue) ?? false
        }
        set {
            MMKV(mmapID: userId)?.set(newValue, forKey: key.rawValue)
        }
    }
    
    static subscript(key: KVStoreKey<Date>) -> Date? {
        get {
            MMKV.default()?.date(forKey: key.rawValue)
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV.default()?.removeValue(forKey: key.rawValue)
                return
            }
            MMKV.default()?.set(value, forKey: key.rawValue)
        }
    }
    
    static subscript(key: KVStoreKey<Date>, userId: String) -> Date? {
        get {
            MMKV(mmapID: userId)?.date(forKey: key.rawValue)
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV(mmapID: userId)?.removeValue(forKey: key.rawValue)
                return
            }
            MMKV(mmapID: userId)?.set(value, forKey: key.rawValue)
        }
    }
    
    static subscript(key: KVStoreKey<Int>) -> Int? {
        get {
            if let int64 = MMKV.default()?.int64(forKey: key.rawValue) {
                return Int(exactly: int64)
            }
            return nil
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV.default()?.removeValue(forKey: key.rawValue)
                return
            }
            if let int64 = Int64(exactly: value) {
                MMKV.default()?.set(int64, forKey: key.rawValue)
            } else if let int32 = Int32(exactly: value) {
                MMKV.default()?.set(int32, forKey: key.rawValue)
            }
        }
    }
    
    static subscript(key: KVStoreKey<Int>, userId: String) -> Int? {
        get {
            guard let value = MMKV(mmapID: userId)?.int64(forKey: key.rawValue) else {
                return nil
            }
            return Int(exactly: value)
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV(mmapID: userId)?.removeValue(forKey: key.rawValue)
                return
            }
            if let int64 = Int64(exactly: value) {
                MMKV(mmapID: userId)?.set(int64, forKey: key.rawValue)
            } else if let int32 = Int32(exactly: value) {
                MMKV(mmapID: userId)?.set(int32, forKey: key.rawValue)
            }
        }
    }
    
    static subscript(key: KVStoreKey<AnyDict>) -> AnyDict? {
        get {
            MMKV.default()?.object(of: NSDictionary.self, forKey: key.rawValue).anyDict
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV.default()?.removeValue(forKey: key.rawValue)
                return
            }
            let dict = NSDictionary.init(dictionary: value)
            MMKV.default()?.set(dict, forKey: key.rawValue)
        }
    }

    static subscript(key: KVStoreKey<AnyDict>, userId: String) -> AnyDict? {
        get {
            MMKV(mmapID: userId)?.object(of: NSDictionary.self, forKey: key.rawValue).anyDict
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV(mmapID: userId)?.removeValue(forKey: key.rawValue)
                return
            }
            let dict = NSDictionary.init(dictionary: value)
            MMKV(mmapID: userId)?.set(dict, forKey: key.rawValue)
        }
    }

    static subscript(key: KVStoreKey<Dict>) -> Dict? {
        get {
            MMKV.default()?.object(of: NSDictionary.self, forKey: key.rawValue).dictionary
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV.default()?.removeValue(forKey: key.rawValue)
                return
            }
            let dict = NSDictionary.init(dictionary: value)
            MMKV.default()?.set(dict, forKey: key.rawValue)
        }
    }

    static subscript(key: KVStoreKey<Dict>, userId: String) -> Dict? {
        get {
            MMKV(mmapID: userId)?.object(of: NSDictionary.self, forKey: key.rawValue).dictionary
        }
        set {
            guard let value = newValue else { // nil == remove value
                MMKV(mmapID: userId)?.removeValue(forKey: key.rawValue)
                return
            }
            let dict = NSDictionary.init(dictionary: value)
            MMKV(mmapID: userId)?.set(dict, forKey: key.rawValue)
        }
    }
    
    static subscript(key: KVStoreKey<Double>, default: Double) -> Double {
        get {
            MMKV.default()?.double(forKey: key.rawValue) ?? `default`
        }
        set {
            MMKV.default()?.set(newValue, forKey: key.rawValue)
        }
    }
}

extension KVStoreKey where T == Bool {
    
    func toggle() {
        KVStore[self] = !KVStore[self]
    }
    
}
