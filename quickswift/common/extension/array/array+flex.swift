//
//  array+flex.swift
//  common
//
//  Created by suyikun on 2022/7/28.
//

import Foundation
import FlexLayout

public extension Array where Element: UIView {
    
    @discardableResult
    func flexMarkDirty() -> [Element] {
        self.forEach({ $0.flex.markDirty() })
        return self
    }
    @discardableResult
    func flexDisplay(_ display: Flex.Display) -> [Element] {
        self.forEach({ $0.flex.display(display) })
        return self
    }
    
    /// 隐藏从 from 到 to 之间的 view
    /// - Parameters:
    ///   - from: from
    ///   - to: to
    /// - Returns:
    @discardableResult
    func flexDisplayNone(from: Int = 0, to: Int) -> [Element] {
        for (idx, v) in self.enumerated() {
            if idx >= from, idx <= to {
                v.flex.display(.none)
            } else {
                v.flex.display(.flex)
            }
        }
        return self
    }
    
    /// 隐藏最后 lastFew 个 view
    /// - Parameter lastFew: Int
    /// - Returns:
    @discardableResult
    func flexDisplayNone(lastFew: Int) -> [Element] {
        for (idx, v) in self.enumerated().reversed() {
            if idx < lastFew {
                v.flex.display(.none)
            } else {
                v.flex.display(.flex)
            }
        }
        return self
    }
}
