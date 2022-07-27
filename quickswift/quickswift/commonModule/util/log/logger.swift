//
//  logger.swift
//  quickswift
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
@discardableResult
func debug(info: Any?) -> String {
    if let info = info {
        print(info)
        return "\(info)"
    }
    return ""
}

func llog(_ v: Any?) {
    if let v = v {
        print(v)
    }
}
func llogWarning(_ v: Any?) {
    if let v = v {
        print(v)
    }
}
class Logger {
     
}
