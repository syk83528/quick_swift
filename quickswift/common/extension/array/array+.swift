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

public extension Array {
    
    func `for`(reversed: Bool = false, _ body: (_ obj: Element, _ index: Int, _ stop: inout Bool, _ isLast: Bool) -> Void) {
        var __stop = false
        var __isLast = false
        var i = 0
        if reversed {
            i = count - 1
            
            for obj in self.reversed() {
                __isLast = (i == 0)
                body(obj, i, &__stop, __isLast)
                if __stop {
                    break
                }
                i -= 1
            }
            return
        }
        for obj in self {
            __isLast = (i == count - 1)
            body(obj, i, &__stop, __isLast)
            if __stop {
                break
            }
            i += 1
        }
    }
    
    func find<T: Equatable>(keyPath: KeyPath<Element, T>, is equal: T?) -> Int {
        var index = -1
        let contains = self.contains(where: { $0[keyPath: keyPath] == equal })
        if !contains { return index }
        
        self.for { (element, idx, stop, _) in
            index = idx
            if element[keyPath: keyPath] == equal {
                stop = true
            }
        }
        return index
    }
    
    func find(_ body: (_ obj: Element, _ index: Int, _ stop: inout Bool) -> Bool) -> Int {
        var index = -1
        self.for { (element, idx, stp, _) in
            index = idx
            if body(element, idx, &stp) {
                stp = true
            }
        }
        return index
    }
    
    func string(_ index: Int) -> String? {
        return self[safe: index] as? String
    }
    func bool(_ index: Int) -> Bool? {
        return self[safe: index] as? Bool
    }
    func array<T>(_ index: Int, type: T.Type) -> [T]? {
        return self[safe: index] as? [T]
    }
    func dict(_ index: Int) -> [AnyHashable: Any]? {
        return self[safe: index] as? [AnyHashable: Any]
    }
    
    @discardableResult
    func `do`(_ element: (Self.Element) -> Void) -> [Element] {
        forEach({ element($0) })
        return self
    }
    
    /// 随机打乱
    /// - Returns: 返回打乱后的数组
    func shuffle() -> [Element] {
        var data: [Element] = self
        for i in 1 ..< data.count {
            let index = Int(arc4random()) % i
            if index != i {
                data.swapAt(i, index)
            }
        }
        return data
    }
}


public extension Array where Element: NSObjectProtocol {
    func makeObjects(perform selector: Selector) {
        for element in self {
            if element.responds(to: selector) {
                element.perform(selector)
            }
        }
    }
}

public extension Array where Element == Substring {
    
    func mapString() -> [String] {
        return self.map(String.init)
    }
}

public extension Array where Element: Equatable & Hashable {
    
    /// please make sure your Eelement: Equatable & Hashable
    /// return index of `member` in array, otherwish `nil`.
    func index(of: Element) -> Int? {
        firstIndex(of: of)
    }
    
    /// use `firstIndex(of:)` find index and remove(at: index) to implement
    mutating func removeFirst(object: Element) {
        if let idx = index(of: object) {
            remove(at: idx)
        }
    }
    /// use `firstIndex(where:)` find the index and remove(at: index) to implement
    mutating func removeFirstWhere(_ match: (Element) -> Bool) {
        if let idx = firstIndex(where: match) {
            remove(at: idx)
        }
    }
    
    /// 替换 object 为 to
    /// - Parameters:
    ///   - object: 被替换的对象
    ///   - to: 替换成的对象
    /// - Returns: 成功返回被替换对象的 index，失败返回 -1
    @discardableResult
    mutating func replace(object: Element?, to: Element?) -> Int {
        guard let object = object, let index = index(of: object), let to = to else {
            return -1
        }
        replaceSubrange(Range<Int>(index...index), with: [to])
        return index
    }
}

public extension Array where Element: NSObject {
    var nsArray: NSArray {
        NSArray(array: self)
    }
}

extension Array {
    
    func prefix(_ string: String) -> [String] {
        map({ "\(string)\($0)" })
    }
    func suffix(_ string: String) -> [String] {
        map({ "\($0)\(string)" })
    }
    static func += (_ array: inout Self, _ item: Element) {
        array.append(item)
    }
}

extension Array where Element: Optionalable {
    func filterNil() -> [Element.Wrapped] {
        compactMap { $0 as? Element.Wrapped }
    }
}

extension ClosedRange where Bound == Int {
    
    func prefix(_ string: String) -> [String] {
        map({ "\(string)\($0)" })
    }
    func suffix(_ string: String) -> [String] {
        map({ "\($0)\(string)" })
    }
    
}

extension Array where Element == Any {
    
    var string: String {
        var temps = ""
        forEach { (element) in
            temps = temps.appending("\(element) ")
        }
        return temps
    }
    
}

extension RandomAccessCollection {

    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}

extension Array where Element: UIView {
    
    func removeAllAnimations() {
        map({ $0.layer }).makeObjects(perform: #selector(CALayer.removeAllAnimations))
    }
}

extension Array where Element == String {
    
    func handlerSJPG() -> [String] {
        var temps: [String] = []
        forEach { (element) in
            temps.append(element.handlerSJPG())
        }
        return temps
    }
    
}

extension Array {
    
    var second: Element? {
        self[safe: 1]
    }
    var third: Element? {
        self[safe: 2]
    }
    var fourth: Element? {
        self[safe: 3]
    }
    var fifth: Element? {
        self[safe: 4]
    }
    var sixth: Element? {
        self[safe: 5]
    }
    var seventh: Element? {
        self[safe: 6]
    }
    var eighth: Element? {
        self[safe: 7]
    }
    var ninth: Element? {
        self[safe: 8]
    }
}
