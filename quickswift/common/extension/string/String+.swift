//
//  String+.swift
//  spsd
//
//  Created by Wildog on 12/28/19.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import CryptoSwift


// MARK: - 正则操作符
/// 正则操作符号
infix operator =~
/// (正则操作, 左边参数为文本, 右边参数为表达式).
public func =~ (content: String, matchs: String) -> Bool {
    return Regex.match(matchs, content)
}

infix operator =<>
public func =<> (content: String, matchs: String) -> NSRange? {
    return Regex.expression(matchs, content: content)
}

infix operator <=>
public func <=> (content: String, matchs: String) -> String? {
    guard let range = content =<> matchs else { return nil }
    return content[range]
}

public extension String {

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }
 
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript(r: PartialRangeFrom<Int>) -> String {
        self[r.lowerBound..<count]
    }
    
    subscript(r: PartialRangeUpTo<Int>) -> String {
        self[0..<r.upperBound]
    }
    
    subscript(r: PartialRangeThrough<Int>) -> String {
        self[0..<(r.upperBound + 1)]
    }

    subscript(r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)), upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }

    subscript(r: NSRange) -> String {
        return (self as NSString).substring(with: r)
//        let range = Range<Int>(uncheckedBounds: (r.location, r.location + r.length))
//        return self[range]
    }
    
    func nsRange(from range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: utf16),
            let to = range.upperBound.samePosition(in: utf16) else {
                return NSRange(location: 0, length: 0)
        }
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
}

public extension String.Index {
    func int(_ string: String) -> Int {
        string.distance(from: string.startIndex, to: self)
    }
    
    func offset(_ offset: String.IndexDistance, in: String) -> String.Index {
        `in`.index(self, offsetBy: offset)
    }
}

extension String {
    func completedPath(host: String) -> String {
        if hasPrefix("http") {
            return self
        }
        if hasPrefix("/") {
            return host + self
        } else {
            return host + "/" + self
        }
    }
    
    func appendQuery(_ query: String, separator: String = "&") -> String {
        if contains("?") {
            return self + separator + query
        } else {
            return self + "?" + query
        }
    }
}

extension String {
    func parseSize(separator: String = ",") -> CGSize {
        var size = CGSize.zero
        guard count > 0 else { return size }
        let values = components(separatedBy: separator)
        if let width = values[safe: 0]?.double {
            size.width = CGFloat(width)
        }
        if let height = values[safe: 1]?.double {
            size.height = CGFloat(height)
        }
        return size
    }
}

public extension String {
    var trim: String {
        self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // TODO number 协议处 实现此方法
    static func simplifiedChinese(with number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "zh_CN")
        numberFormatter.numberStyle = .spellOut
        return numberFormatter.string(from: NSNumber(value: number)) ?? ""
    }

    /// (随机生成字符串).
    static func random(_ length: Int, base: String = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789") -> String {
        guard length.isPositive else { return "" }
        var randomString = ""
        for _ in 1 ... length {
            let randomIndex = arc4random_uniform(UInt32(base.count))
            let randomCharacter = Array(base)[Int(randomIndex)]
            randomString.append(randomCharacter)
        }
        return randomString
    }

    /// 拼接 paths 中的路径, 忽略 "" 空路径
    func append(path: String...) -> String {
        var str = self
        for p in path {
            if p == "" { continue }
            if str.hasSuffix("/") {
                if p.hasPrefix("/") {
                    var _p = p
                    _p.removeFirst()
                    str += _p
                } else {
                    str += p
                }
                continue
            } else {
                if p.hasPrefix("/") {
                    str += p
                } else {
                    str += "/" + p
                }
            }
        }
        return str
    }

    func hasPrefix(_ prefixes: String...) -> Bool {
        for pre in prefixes {
            if self.hasPrefix(pre) {
                return true
            }
        }
        return false
    }

    func replace(_ string: String, to: String) -> String {
        return self.replacingOccurrences(of: string, with: to)
    }
    
    func replaceFirst(_ string: String, to: String) -> String {
        guard let range = range(of: string) else { return self }
        return replacingOccurrences(of: string, with: to, options: [], range: range)
    }

    /// (移除包含在 strings 里面的的字符串).
    @discardableResult
    func remove(_ strings: String...) -> String {
        var temp = self
        strings.forEach({ temp = temp.replace($0, to: "") })
        return temp
    }

    /// (存在任意一个即返回 true).
    @discardableResult
    func containses(_ strings: String...) -> Bool {
        strings.contains(where: { self.contains($0) })
    }

    func copyToPasteboard() {
        UIPasteboard.general.string = self
    }
    
    var moduleAndPath: (String?, String?) {
        var module: String?
        var path: String?
        if count > 1 {
            let temp = components(separatedBy: "/")
            module = temp.first
            path = temp[safe: 1..<temp.endIndex].joined(separator: "/")
            if let p = path {
                path = "/" + p
            }
        }
        return (module, path)
    }
    
    var queryParams: [String: String] {

        var result: [String: String] = [:]
        
        for pair in components(separatedBy: "&") where pair.count > 0 {
            var key: String, value: String
            
            if let range = pair.range(of: "=") {
                key = String(pair[..<range.lowerBound])
                value = String(pair[range.upperBound...])
            } else {
                key = pair
                value = ""
            }
            
            if let key = key.removingPercentEncoding, key.count > 0 {
                result[key] = value.removingPercentEncoding ?? value
            }
        }

        return result
    }
    /// 如果字符串为空（.count = 0), 则返回 default
    func empty(_ `default`: String) -> String {
        if self.count == 0 {
            return `default`
        }
        return self
    }
    /// 截取字符串
    func truncated(length: Int) -> String {
        if self.count <= length {
            return self
        }
        if length >= 4 {
            let str = NSString(string: self)
            let emojiRange = str.rangeOfComposedCharacterSequences(for: NSRange(location: 2, length: length - 2))
            if emojiRange.location != NSNotFound {
                let emojiLastLocation = emojiRange.location + emojiRange.length - 1
                if emojiLastLocation >= length {
                    return str.substring(to: min(length, emojiRange.location)).appending("...")
                }
            }
        }
        return self.substring(toIndex: length).appending("…")
    }
}

extension String {
    var firstLatin: String {
        prefix(1).string.latin.prefix(1).string
    }

    var latin: String {
        guard let string = self.nsString.mutableCopy() as? NSMutableString else {
            return ""
        }
        CFStringTransform(string, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(string, nil, kCFStringTransformStripDiacritics, false)
        return string.capitalized
    }
}

// MARK: - String Variable
public extension String {

    var url: URL? {
        URL.init(string: self)
    }

    /// Just get `image-file` from `Assets.xcassets`
    var image: UIImage? {
        UIImage(named: self)
    }

    /// Convert to NSString
    var nsString: NSString {
        self as NSString
    }

    /// Convert to Int
    /// (转换为整数).
    ///     "123".toInt -> 123
    ///     "135abc35".toInt -> 135
    ///     "abc123".toInt -> 0
    var int: Int {
        let text = self.nsString
        return text.integerValue
    }
    
    // 64
    var int64: Int64 {
        let text = self.nsString
        return text.longLongValue
    }
    
    var uInt: UInt {
        UInt(self.int)
    }

    /// Convert to Float
    var float: Float {
        let text = self.nsString
        return text.floatValue
    }

    /// Convert to Double
    var double: Double {
        let text = self.nsString
        return text.doubleValue
    }
    /// Convert to CGFloat
    var cgFloat: CGFloat {
        let text = self.nsString
        return text.floatValue.cgFloat
    }
    /// Convert to TimeInterval
    var interval: TimeInterval {
        double as TimeInterval
    }

    var fileURL: URL {
        URL.init(fileURLWithPath: self)
    }

    var base64Encode: String? {
        data(using: .utf8)?.base64EncodedString()
    }

    var base64: Data? {
        data(using: .utf8)?.base64EncodedData()
    }

    var base64Decode: String? {
        guard let decodeData = Data(base64Encoded: self) else { return nil }
        return String(data: decodeData, encoding: .utf8)
    }

    var urlEncode: String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    /// (URL 解码).
    var urlDecode: String? {
        removingPercentEncoding ?? nil
    }

    /// (获取最后一个字符串).
    var last: String {
        (self.count == 1) ? self : self[self.index(before: self.endIndex)...].string
    }

    /// (移除最后一个字符串, 返回移除后的字符串).
    var removeLast: String {
        guard self == "" else {
            var temp = self
            temp.remove(at: temp.index(before: temp.endIndex))
            return temp
        }
        return self
    }
    /// 若最后一位是分隔符“/” 则返回删除后的
    var removeLastSeparator: String {
        guard self == "" else {
            if self.last == "/" {
                return self.removeLast
            } else {
                return self
            }
        }
        return self
    }
    var removeSpace: String {
        guard self == "" else {
            return String(self.filter { !$0.isWhitespace })
        }
        return self
    }

    /// (获取扩展名).
    var pathExtension: String {
        (self as NSString).pathExtension
    }

    /// (获取文件名, 有扩展名).
    var lastPath: String {
        (self as NSString).lastPathComponent
    }
    
    /// 分割符: /，取最后一个数据
    var lastURLPath: String? {
        components(separatedBy: "/").last
    }

    /// (第一个字符大写).
    var uppercaseFirst: String {
        self.uppercased(with: Locale.current)
    }

    /// (是否为电子邮件).
    var isEmail: Bool {
        // http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        let email = "[A-Z0-9a-z._%+-\\u4e00-\\u9fa5]+@[A-Za-z0-9.-\\u4e00-\\u9fa5]+\\.[A-Za-z\\u4e00-\\u9fa5]{2,}"// "^[A-Z0-9a-z._%+-]+@[A-Za-z]{2,4}$"
        return self =~ email
    }
    
    var ipAddress: String? {
        
        // ((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}
        self <=> "((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}"
    }

    var isPhoneNumber: Bool {
        // 号码一直在添加，服务端判断
        self =~ "^1[3-9]\\d{9}$"
    }

    var isIDCardNumber: Bool {
        self =~ "^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$"
    }

    /// (随机生成一个 32 位字符串).
    static var random32Bit: String {
        String.random(32)
    }

    /// (返回词组).
    /// From SwifterSwift.
    ///     "Swift is so faster".words() -> ["Swift", "is", "so", "faster"]
    ///     "我 今天 吃了五碗饭".words() -> ["我", "今天", "吃了五碗饭"]
    ///     "我,今天,吃了五碗饭".words() -> ["我", "今天", "吃了五碗饭"]
    ///     "我-今天-吃了五碗饭".words() -> ["我", "今天", "吃了五碗饭"]
    ///     "我,今天-吃了五碗饭".words() -> ["我", "今天", "吃了五碗饭"]
    ///     "我今天吃了五碗饭".words() -> ["我今天吃了五碗饭"]
    var words: [String] {
        // https://stackoverflow.com/questions/42822838
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let comps = components(separatedBy: chararacterSet)
        return comps.filter { !$0.isEmpty }
    }

    /// (是否全为数字).
    var isNumber: Bool {
        // ^\\d$
        self =~ "^\\d+$"
    }
}


extension String {
    static func uuid(dashed: Bool = false) -> String {
        let uuid = NSUUID().uuidString
        if dashed {
            return uuid
        } else {
            return uuid.replace("-", to: "").lowercased()
        }
    }
    
    var md5: String {
        self.md5()
    }
}

extension String {
    
    func handlerSJPG() -> String {
        if hasSuffix("/s.jpg") {
            return self.replace("/s.jpg", to: "/l.jpg")
        }
        return self
    }
    func handlerLJPG() -> String {
        if hasSuffix("/l.jpg") {
            return self.replace("/l.jpg", to: "/s.jpg")
        }
        return self
    }
    
    func parseJSON() -> Any? {
        guard self.count > 0 else { return nil }
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
    }
}

extension CFString {
    var string: String {
        self as String
    }
}
