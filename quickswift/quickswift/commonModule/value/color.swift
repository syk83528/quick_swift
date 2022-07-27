//
//  color.swift
//  quickswift
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import UIKit

public extension UIColor {
    /// .pink
    static var primary: UIColor {
        .primaryPink
    }
    
    /// #FF79E5
    static var primaryPink: UIColor {
        .hex(0xFF79E5)
    }
    /// #6F73FE
    static var primaryBlue: UIColor {
        .hex(0x6F73FE)
    }
    
    /// #F7F8FA
    static var backgroundColor: UIColor {
        .hex(0xF7F8FA)
    }
    
    /// 主文本色, #333333
    static var title: UIColor {
        .hex(0x333333)
    }
    /// 子标题, 0x6D6E73
    static var subTitle: UIColor {
        .hex(0x6D6E73)
    }
    /// #666666
    static var text: UIColor {
        .hex(0x666666)
    }
    /// 子文本, #999999
    static var subText: UIColor {
        .hex(0x999999)
    }
    
    /// 占位符颜色 #DDDDDD
    static var placeholder: UIColor {
        .hex(0xDDDDDD)
    }
    
    /// line, #ECECEC.alpha(0.4)
    static var line: UIColor {
        hex(0xECECEC, 0.8)
    }

    static var placeholderTitle: UIColor {
        .hex(0xc0c0c0)
    }
    
    static var dotColor: UIColor {
        .hex(0xFB5D5D)
    }
    
    /// #FF196B
    static var oldPink: UIColor {
        .hex(0xFF196B)
    }
    
    /// #FF4D85
    static var customPink: UIColor {
        .hex(0xFF4D85)
    }
    /// #0xFF79E5
    static var female: UIColor {
        .hex(0xFF79E5)
    }
    /// #0x6F73FE
    static var male: UIColor {
        .hex(0x6F73FE)
    }
    
    /// 0xFF196B
    static var disabled: UIColor {
        .hex(0xC9C9C9)
    }
    
}
