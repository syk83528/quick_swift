//
//  Dictionary+.swift
//  spsd
//
//  Created by 未来 on 2019/12/11.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import SwiftyJSON

public extension Dictionary {
    
    mutating func merge(from: Dictionary?) {
        guard let from = from else { return }
        from.forEach { (d) in
            let (k, v) = d
            updateValue(v, forKey: k)
        }
    }
    
    mutating func merges(from: [Dictionary?]) {
        guard from.count != 0 else { return }
        from.forEach { (d) in
            merge(from: d)
        }
    }
    
    func merging(_ other: [Key: Value]?) -> [Key: Value] {
        guard let other = other else { return self }
        return self.merging(other) { (_, new) -> Value in
            new
        }
    }
}

public extension Dictionary where Key: Hashable {
    func equalTo(_ other: Dictionary) -> Bool {
        (self as NSDictionary).isEqual(to: other)
    }
    
    var json: JSON {
        JSON(self)
    }
}

public extension Dictionary where Value: Optionalable {
    func filterNil() -> [Key: Value.Wrapped] {
        var newDictionary: [Key: Value.Wrapped] = [:]
        for (key, value) in self {
            guard let value = value.wrapped else { continue }
            newDictionary[key] = value
        }
        return newDictionary
    }
}

public extension Dictionary {
    subscript<T>(key: Key, type: T.Type) -> T? {
        self[key] as? T
    }
    
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }
}

public extension Dictionary where Key: Hashable {
    
    func string(_ forKey: Key) -> String? {
        self[forKey] as? String
    }

    func bool(_ forKey: Key) -> Bool? {
        self[forKey] as? Bool
    }

    func array<T>(_ forKey: Key, type: T.Type) -> [T]? {
        self[forKey] as? [T]
    }
    
    func rect(_ forKey: Key) -> CGRect? {
        self[forKey] as? CGRect
    }

    func dict(_ forKey: Key) -> [String: Any]? {
        self[forKey] as? [String: Any]
    }
    
    /// return 0 if convert failed.
    func int(_ forKey: Key) -> Int {
        "\(String(describing: self[forKey]))".int
    }
    func float(_ forKey: Key) -> Float? {
        "\(String(describing: self[forKey]))".float
    }
    func interval(_ forKey: Key) -> TimeInterval {
        "\(String(describing: self[forKey]))".interval
    }
}
