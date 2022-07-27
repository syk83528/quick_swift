//
//  DispatchQueue+.swift
//  IWBaseKits
//
//  Created by 未来 on 2019/4/3.
//  Copyright © 2019 iWECon. All rights reserved.
//

#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

public extension DispatchQueue {
    
    private static var _oneceToken = [String]()
    
    static func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        guard !_oneceToken.contains(token) else { return }
        _oneceToken.append(token)
        block()
    }
}
