//
//  Label+.swift
//  spsd
//
//  Created by 未来 on 2019/12/11.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit

private struct LabelKey {
    static let lineSpacing = "_lineSpacing"
}

public extension UILabel {
    
    /// 设置完字体之后使用
    @IBInspectable
    var textLineSpacing: CGFloat {
        get {
            cgFloatProperty(for: LabelKey.lineSpacing).or(10)
        }
        set {
            setCGFloatProperty(for: LabelKey.lineSpacing, newValue)
            if newValue != 0, text.orEmpty.count > 0 {
                update(text: self.text!)
            }
        }
    }
    
    /// text 会使用 lineSpacing
    func update(text: String) {
        if text.count <= 0 || textLineSpacing <= 10 {
            self.text = text
            return
        }
        attributedText = text.mutableAttr.lineSpacing(self.textLineSpacing).alignment(.left).apply()
    }
    
}

public extension UILabel {
    
    /// set size of regular
    var fontSize: CGFloat {
        get {
            self.font.pointSize
        }
        set {
            self.font = .systemFont(ofSize: newValue, weight: .regular)
        }
    }
    
    var anyText: Any? {
        get {
            self.text
        }
        set {
            if let str = newValue as? String {
                self.text = str
            } else if let attr = newValue as? NSAttributedString {
                self.attributedText = attr
            }
        }
    }
}

public extension UILabel {
    convenience init(text: String? = nil, font: UIFont? = nil, color: UIColor? = nil, numberOfLines: Int? = 1, alignment: NSTextAlignment? = nil) {
        self.init()
        if let text = text { self.text = text }
        if let font = font { self.font = font }
        if let color = color { self.textColor = color }
        if let alignment = alignment { self.textAlignment = alignment }
        if let numberOfLines = numberOfLines { self.numberOfLines = numberOfLines }
    }
}

public extension UILabel {

    convenience init(_ text: String) {
        self.init()
        self.text = text
    }

    func alignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment = alignment
        return self
    }
    func textColor(_ color: UIColor) -> Self {
        textColor = color
        return self
    }
}
