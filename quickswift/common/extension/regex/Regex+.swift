//
//  IWRegex.swift
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

/// Regex correlation.
/// (正则表达式相关).
public class Regex: NSObject {
    
    /// is contain matching text?
    /// (是否包含匹配的文本).
    /// matches: expression(表达式)
    /// content: 被查找的文本
    class func match(_ matches: String, _ content: String) -> Bool {
        let regex = try? NSRegularExpression.init(pattern: matches, options: [.caseInsensitive, .dotMatchesLineSeparators])
        if let matchResult = regex?.matches(in: content, options: .withTransparentBounds, range: NSRange(location: 0, length: content.utf16.count)) {
            return matchResult.count > 0
        }
        return false
    }
    
    /// Matching exp, return finded str.
    /// (匹配表达式, 返回找到的字符串).
    class func expression(_ expression: String, content: String) -> NSRange? {
        let tempBody = content
        do {
            let regex = try NSRegularExpression.init(pattern: expression, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let firstMatch = regex.firstMatch(in: tempBody, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: tempBody.utf16.count))
            if let match = firstMatch {
                return match.range
            }
            return nil
        } catch {
            return nil
        }
    }
    
    class func expression(_ expression: String, options: NSRegularExpression.Options = []) -> NSRegularExpression? {
        do {
            let regex = try NSRegularExpression.init(pattern: expression, options: options)
            return regex
        } catch {
            return nil
        }
    }
    
}
extension NSRegularExpression {
    
    func enumerateMatches(in string: String,
                          options: MatchingOptions = [],
                          range: Range<String.Index>,
                          using block: (_ result: NSTextCheckingResult?, _ flags: MatchingFlags, _ stop: inout Bool) -> Void) {
        
        enumerateMatches(in: string, options: options, range: NSRange(range, in: string)) { result, flags, stop in
            var shouldStop = false
            block(result, flags, &shouldStop)
            if shouldStop {
                stop.pointee = true
            }
        }
    }
    
}

extension NSRegularExpression {
    
    func m(in content: String, do block: (_ range: NSRange, _ stop: inout Bool) -> Void) {
        guard let r = Range<String.Index>.init(NSRange(location: 0, length: content.utf16.count), in: content) else { return }
        enumerateMatches(in: content, range: r) { (result, _, stop) in
            if let re = result {
                block(re.range, &stop)
            }
        }
    }
}
