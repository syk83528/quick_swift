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
