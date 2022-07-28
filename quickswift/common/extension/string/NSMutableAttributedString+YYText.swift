//
//  NSMutableAttributedString+YYText.swift
//  spsd
//
//  Created by iWw on 2022/1/21.
//  Copyright © 2022 未来. All rights reserved.
//

import UIKit
import YYText

public extension String {
    var mutableAttr: NSMutableAttributedString {
        NSMutableAttributedString(string: self)
    }
}
public extension NSAttributedString {
    var mutableAttr: NSMutableAttributedString {
        NSMutableAttributedString(attributedString: self)
    }
}

fileprivate extension Keys {
    struct MutableAttributedString {
        static var lineSpacing = "MutableAttributedString.lineSpacing"
        static var font = "MutableAttributedString.font"
        static var fontSize = "MutableAttributedString.fontSize"
        static var textColor = "MutableAttributedString.textColor"
        static var textShadow = "MutableAttributedString.textShadow"
        static var alignment = "MutableAttributedString.alignment"
        static var lineOffset = "MutableAttributedString.lineOffset"
        static var underlineColor = "MutableAttributedString.underlineColor"
        static var strikethroughColor = "MutableAttributedString.strikethroughColor"
        static var lineBreakMode = "MutableAttributedString.lineBreakMode"
    }
}

public extension NSMutableAttributedString {
    
    var rangeOfAll: NSRange {
        NSRange(location: 0, length: string.utf16.count)
    }
    
    fileprivate var lineSpacing: CGFloat {
        get { cgFloatProperty(for: &Keys.MutableAttributedString.lineSpacing) ?? 0 }
        set { setCGFloatProperty(for: &Keys.MutableAttributedString.lineSpacing, newValue) }
    }
    fileprivate var font: UIFont? {
        get { property(for: &Keys.MutableAttributedString.font) as? UIFont }
        set { setProperty(for: &Keys.MutableAttributedString.font, newValue) }
    }
    fileprivate var fontSize: CGFloat {
        get { cgFloatProperty(for: &Keys.MutableAttributedString.fontSize) ?? 0 }
        set { setCGFloatProperty(for: &Keys.MutableAttributedString.fontSize, newValue) }
    }
    fileprivate var textColor: UIColor? {
        //        get { (property(for: &Keys.MutableAttributedString.textColor) as? UIColor) ?? .black }
        get { (property(for: &Keys.MutableAttributedString.textColor) as? UIColor) }
        set { setProperty(for: &Keys.MutableAttributedString.textColor, newValue) }
    }
    fileprivate var textShadow: YYTextShadow? {
        get { property(for: &Keys.MutableAttributedString.textShadow) as? YYTextShadow }
        set { setProperty(for: &Keys.MutableAttributedString.textShadow, newValue) }
    }
    fileprivate var boldFontSize: CGFloat {
        get { font?.pointSize ?? 0 }
        set { font = .systemFont(ofSize: newValue, weight: .bold) }
    }
    fileprivate var mediumFontSize: CGFloat {
        get { font?.pointSize ?? 0 }
        set { font = .systemFont(ofSize: newValue, weight: .medium) }
    }
    fileprivate var semiboldFontSize: CGFloat {
        get { font?.pointSize ?? 0 }
        set { font = .systemFont(ofSize: newValue, weight: .semibold) }
    }
    fileprivate var alignment: NSTextAlignment? {
        get {
            if let al = (property(for: &Keys.MutableAttributedString.alignment) as? Int) {
                return NSTextAlignment.init(rawValue: al)
            } else {
                return nil
            }
        }
        set { setProperty(for: &Keys.MutableAttributedString.alignment, newValue?.rawValue, policy: .OBJC_ASSOCIATION_ASSIGN) }
    }
    fileprivate var lineOffset: CGFloat {
        get { cgFloatProperty(for: &Keys.MutableAttributedString.lineOffset) ?? 0 }
        set { setCGFloatProperty(for: &Keys.MutableAttributedString.lineOffset, newValue) }
    }
    fileprivate var underlineColor: UIColor? {
        get { (property(for: &Keys.MutableAttributedString.underlineColor) as? UIColor) ?? nil }
        set { setProperty(for: &Keys.MutableAttributedString.underlineColor, newValue) }
    }
    fileprivate var strikethroughColor: UIColor? {
        get { (property(for: &Keys.MutableAttributedString.strikethroughColor) as? UIColor) ?? nil }
        set { setProperty(for: &Keys.MutableAttributedString.strikethroughColor, newValue) }
    }
    fileprivate var lineBreakMode: NSLineBreakMode? {
        get { (property(for: &Keys.MutableAttributedString.lineBreakMode) as? NSLineBreakMode) ?? nil }
        set { setProperty(for: &Keys.MutableAttributedString.lineBreakMode, newValue, policy: .OBJC_ASSOCIATION_RETAIN) }
    }
}

public extension NSMutableAttributedString {
    
    @discardableResult
    static func += (_ lhs: NSMutableAttributedString, _ rhs: NSMutableAttributedString) -> NSMutableAttributedString {
        lhs.append(rhs)
        return lhs
    }
    
    
    /// copy `text color`, `textShadow`, `lineSpacing` and `font` from `from`
    func copy(_ from: NSAttributedString) -> NSMutableAttributedString {
        self.lineSpacing = from.yy_lineSpacing
        self.font = from.yy_font
        self.textColor = from.yy_color
        self.textShadow = from.yy_textShadow
        self.lineBreakMode = from.yy_lineBreakMode
        return self
    }
    /// 用整数, 小数会导致 Crash, 具体原因未知, 后续再看
    func lineSpacing(_ value: CGFloat) -> NSMutableAttributedString {
        self.lineSpacing = value
        return self
    }
    func font(_ font: UIFont?) -> NSMutableAttributedString {
        self.font = font
        return self
    }
    func textColor(_ textColor: UIColor?) -> NSMutableAttributedString {
        self.textColor = textColor
        return self
    }
    func textShadow(_ textShadow: YYTextShadow?) -> NSMutableAttributedString {
        self.textShadow = textShadow
        return self
    }
    func alignment(_ textAlignment: NSTextAlignment) -> NSMutableAttributedString {
        self.alignment = textAlignment
        return self
    }
    func fontSize(_ systemFontSize: CGFloat) -> NSMutableAttributedString {
        font(.systemFont(ofSize: systemFontSize))
    }
    func bold(_ fontSize: CGFloat) -> NSMutableAttributedString {
        self.boldFontSize = fontSize
        return self
    }
    func medium(_ fontSize: CGFloat) -> NSMutableAttributedString {
        self.font = .systemFont(ofSize: fontSize, weight: .medium)
        return self
    }
    func semibold(_ fontSize: CGFloat) -> NSMutableAttributedString {
        self.font = .systemFont(ofSize: fontSize, weight: .semibold)
        return self
    }
    func baseLineOffset(_ offset: CGFloat) -> NSMutableAttributedString {
        self.lineOffset = offset
        return self
    }
    func underlineColor(_ color: UIColor) -> NSMutableAttributedString {
        self.underlineColor = color
        return self
    }
    func strikethroughColor(_ color: UIColor) -> NSMutableAttributedString {
        self.strikethroughColor = color
        return self
    }
    func lineBreakMode(_ mode: NSLineBreakMode) -> NSMutableAttributedString {
        self.lineBreakMode = mode
        return self
    }
    
    /// Apply the above attributes to range
    @discardableResult
    func apply(_ range: NSRange = .init(location: 0, length: 0), shouldClean: Bool = true) -> NSMutableAttributedString {
        guard string.count != 0 else { return NSMutableAttributedString(string: "") }
        
        let applyRange = (range.location == 0 && range.length == 0) ? rangeOfAll : range
        if let textColor = textColor {
            yy_setColor(textColor, range: applyRange)
        }
        yy_setFont(font, range: applyRange)
        yy_setTextShadow(textShadow, range: applyRange)
        yy_setLineSpacing(lineSpacing, range: applyRange)
        if let alignment = alignment {
            yy_setAlignment(alignment, range: applyRange)
        }
        if lineOffset > 0 {
            yy_setBaselineOffset(NSNumber(value: lineOffset.float), range: applyRange)
        }
        if let uc = underlineColor {
            yy_setUnderlineColor(uc, range: applyRange)
            yy_setUnderlineStyle(.single, range: applyRange)
        }
        if let sc = strikethroughColor {
            yy_setStrikethroughColor(sc, range: applyRange)
            yy_setStrikethroughStyle(.single, range: applyRange)
        }
        if let lineBreakMode = lineBreakMode {
            yy_setLineBreakMode(lineBreakMode, range: applyRange)
        }
        
        if shouldClean {
            textColor = nil
            underlineColor = nil
            strikethroughColor = nil
            lineBreakMode = nil
            lineOffset = 0
            alignment = nil
        }
        return self
    }
    
    // 匹配到的内容全部替换
    // 如果只需要匹配第一个，matchAll 给 false 就行
    @discardableResult
    func apply(_ match: String, matchAll: Bool = true, shouldClean: Bool = false) -> NSMutableAttributedString {
        guard let regex = Regex.expression(match) else {
            return self
        }
        regex.m(in: string) { (range, stop) in
            apply(range, shouldClean: shouldClean)
            if !matchAll {
                stop = true
            }
        }
        return self
    }
}
