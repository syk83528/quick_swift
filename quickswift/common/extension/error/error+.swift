//
//  error+.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation

public extension Error {
    /// (self as NSError).code
    var code: Int {
        return (self as NSError).code
    }
}

public extension NSError {
    convenience init(message: String?, code: Int = -1, domain: String = "dx.duixiang.app") {
        self.init(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: message ?? ""])
    }
}

public extension LocalizedError where Self: CustomStringConvertible {
    var errorDescription: String? {
        description
    }
}
