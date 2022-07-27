//
//  array+.swift
//  quickswift
//
//  Created by suyikun on 2022/7/26.
//

import Foundation

public extension Array {
    
    subscript (safe range: Range<Int>) -> ArraySlice<Element> {
        let startIndex = Swift.max(self.startIndex, range.lowerBound)
        if count == 0 || startIndex > count {
            return ArraySlice<Element>()
        }
        let safeRange = Range<Int>(uncheckedBounds: (startIndex, Swift.min(self.endIndex, range.upperBound)))
        return self[safeRange]
    }
    
    subscript (safe index: Int) -> Element? {
        return (0 ..< count).contains(index) ? self[index] : nil
    }
}
