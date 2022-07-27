//
//  Color+.swift
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

public extension UIColor {
    
    /// r.g.b 为 0-255 之间的数字
    convenience init(r red: CGFloat, g green: CGFloat, b blue: CGFloat, a alpha: CGFloat = 1.0) {
        self.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    @available(iOS 9.3, *)
    convenience init(hex: UInt, a alpha: CGFloat = 1) {
        let limit: CGFloat = 255
        let r: CGFloat = CGFloat((hex & 0xFF0000) >> 16) / limit
        let g: CGFloat = CGFloat((hex & 0x00FF00) >> 8) / limit
        let b: CGFloat = CGFloat((hex & 0x0000FF)) / limit
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    #if os(iOS)
    /// (返回一张 4x4 的纯色图片).
    final var image: UIImage? {
        return image()
    }
    #endif
    
}

public extension UIColor {
    
    /// (返回一个随机颜色).
    static var random: UIColor {
        let red = CGFloat(arc4random() % 255) / 255.0
        let gre = CGFloat(arc4random() % 255) / 255.0
        let blu = CGFloat(arc4random() % 255) / 255.0
        return UIColor(red: red, green: gre, blue: blu, alpha: 1.0)
    }
    
    /// (返回一个随机的暗色).
    static var randomWithDark: UIColor {
        var randomColor = UIColor.random
        while !randomColor.isDark {
            randomColor = UIColor.random
        }
        return randomColor
    }
    
    /// (返回一个随机的亮色).
    static var randomWithLight: UIColor {
        var randomColor = UIColor.random
        while !randomColor.isLight {
            randomColor = UIColor.random
        }
        return randomColor
    }
    
    /// (返回当前颜色的反色).
    final var inverseColor: UIColor? {
        guard let componentColors = self.cgColor.components else { return nil }
        let newColor = UIColor.init(red: 1.0 - componentColors[0], green: 1.0 - componentColors[1], blue: 1.0 - componentColors[3], alpha: componentColors[3])
        return newColor
    }
    
    /// (是否为暗色).
    final var isDark: Bool {
        var red: CGFloat = 0.0, gre: CGFloat = 0.0, blu: CGFloat = 0.0, alpha: CGFloat = 0.0
        self.getRed(&red, green: &gre, blue: &blu, alpha: &alpha)
        let referenceValue: CGFloat = 0.411
        let colorDelta = (red * 0.299) + (gre * 0.587) + (blu * 0.114)
        return (1.0 - colorDelta) > referenceValue
    }
    
    /// (是否为亮色).
    final var isLight: Bool {
        return !isDark
    }
    /// (按钮默认的蓝色).
    static var defaultOfButton: UIColor {
        return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    }
    
    static func cgColor(_ uiColor: UIColor, alpha: CGFloat = 1.0) -> CGColor {
        uiColor.alpha(alpha).cgColor
    }
    
    /// (十六进制颜色).
    static func hex(_ hex: String, _ alpha: CGFloat = 1.0) -> UIColor {
        var color = UIColor.red
        var cStr: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if cStr.hasPrefix("#") {
            let index = cStr.index(after: cStr.startIndex)
            cStr = String(cStr[index...]) // cStr.iwe.substring(from: index)
        }
        if cStr.count != 6 {
            return UIColor.black
        }
        
        let rRange = cStr.startIndex ..< cStr.index(cStr.startIndex, offsetBy: 2)
        let rStr = String(cStr[rRange]) // cStr.iwe.substring(with: rRange)
        
        let gRange = cStr.index(cStr.startIndex, offsetBy: 2) ..< cStr.index(cStr.startIndex, offsetBy: 4)
        let gStr = String(cStr[gRange]) // cStr.iwe.substring(with: gRange)
        
        let bIndex = cStr.index(cStr.endIndex, offsetBy: -2)
        let bStr = String(cStr[bIndex...]) // cStr.iwe.substring(from: bIndex)
        
        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0
        Scanner(string: rStr).scanHexInt32(&r)
        Scanner(string: gStr).scanHexInt32(&g)
        Scanner(string: bStr).scanHexInt32(&b)
        
        color = UIColor(red: CGFloat(r) / 255.0,
                        green: CGFloat(g) / 255.0,
                        blue: CGFloat(b) / 255.0,
                        alpha: CGFloat(alpha))
        return color
    }
    
    static func hex(_ hex: UInt, _ alpha: CGFloat = 1.0) -> UIColor {
        let limit: CGFloat = 255
        let r: CGFloat = CGFloat((hex & 0xFF0000) >> 16) / limit
        let g: CGFloat = CGFloat((hex & 0x00FF00) >> 8) / limit
        let b: CGFloat = CGFloat((hex & 0x0000FF)) / limit
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
    
    #if os(iOS)
    /// (返回一张自定义的纯色图片).
    ///
    /// - Parameters:
    ///   - color: 图片颜色
    ///   - size: 图片大小, 默认为 4x4
    ///   - cornerRadius: 图片圆角
    /// - Returns: 图片, 可能为nil
    final func image(size: CGSize = CGSize(width: 4, height: 4), cornerRadius: CGFloat = 0) -> UIImage? {
        func removeFloatMin(_ floatValue: CGFloat) -> CGFloat {
            return floatValue == CGFloat.min ? 0 : floatValue
        }
        func flatSpecificScale(_ floatValue: CGFloat, _ scale: CGFloat) -> CGFloat {
            let fv = removeFloatMin(floatValue)
            let sc = (scale == 0 ? UIScreen.main.scale : scale)
            let flattedValue = ceil(fv * sc) / sc
            return flattedValue
        }
        func flat(_ floatValue: CGFloat) -> CGFloat {
            return flatSpecificScale(floatValue, 0)
        }
        let sz = CGSize(width: flat(size.width), height: flat(size.height))
        if sz.width < 0 || sz.height < 0 { assertionFailure("CGPostError, 非法的 size") }
        
        var resultImage: UIImage?
        
        var coAlpha: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &coAlpha)
        let opaque = (cornerRadius == 0.0 && coAlpha == 1.0)
        UIGraphicsBeginImageContextWithOptions(sz, opaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("非法 context.")
            return nil
        }
        context.setFillColor(cgColor)
        
        if cornerRadius > 0 {
            let path = UIBezierPath.init(roundedRect: sz.rect, cornerRadius: cornerRadius)
            path.addClip()
            path.fill()
        } else {
            context.fill(sz.rect)
        }
        
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    #endif
    
    /// (.withAlphaComponent()).
    func alpha(_ value: CGFloat) -> UIColor {
        return self.withAlphaComponent(value)
    }
    
    /// (返回当前颜色 红色 通道的值).
    final var redChannel: CGFloat {
        var r: CGFloat = 0
        if self.getRed(&r, green: nil, blue: nil, alpha: nil) {
            return r
        }
        return 0
    }
    
    /// (返回当前颜色 绿色 通道的值).
    final var greenChannel: CGFloat {
        var g: CGFloat = 0
        if self.getRed(nil, green: &g, blue: nil, alpha: nil) {
            return g
        }
        return 0
    }
    
    /// (返回当前颜色 蓝色 通道的值).
    final var blueChannel: CGFloat {
        var b: CGFloat = 0
        if self.getRed(nil, green: nil, blue: &b, alpha: nil) {
            return b
        }
        return 0
    }
    
    /// (返回当前颜色 透明 通道的值).
    final var alphaChannel: CGFloat {
        var a: CGFloat = 0
        if self.getRed(nil, green: nil, blue: nil, alpha: &a) {
            return a
        }
        return 0
    }
    
    /// (返回当前颜色 hue 通道的值).
    final var hueChannel: CGFloat {
        var h: CGFloat = 0
        if self.getHue(&h, saturation: nil, brightness: nil, alpha: nil) {
            return h
        }
        return 0
    }
    
    /// (返回当前颜色 saturation 通道的值).
    final var saturation: CGFloat {
        var s: CGFloat = 0
        if self.getHue(nil, saturation: &s, brightness: nil, alpha: nil) {
            return s
        }
        return 0
    }
    
    /// (返回当前颜色 brightness 通道的值).
    final var brightness: CGFloat {
        var b: CGFloat = 0
        if self.getHue(nil, saturation: nil, brightness: &b, alpha: nil) {
            return b
        }
        return 0
    }
    func brightness(_ value: CGFloat) -> UIColor {
        UIColor.init(hue: self.hueChannel, saturation: self.saturation, brightness: value, alpha: self.alphaChannel)
    }
    /// 0-1
    func alphaChannel(_ value: CGFloat) -> UIColor {
        UIColor.init(hue: self.hueChannel, saturation: self.saturation, brightness: self.brightness, alpha: value)
    }
    func saturation(_ value: CGFloat) -> UIColor {
        UIColor.init(hue: self.hueChannel, saturation: value, brightness: self.brightness, alpha: self.alphaChannel)
    }
    
}

public extension UIColor {
    
    /// 当前颜色到 newColor 颜色的值，progress 为进度，在 0-1 之间取值
    /// 适用于滑动时候更改颜色用
    /// - Parameters:
    ///   - color: 新的颜色
    ///   - progress: 进度
    func to(new color: UIColor, progress: CGFloat) -> UIColor {
        guard self != color else { return self }
        
        var p = progress
        if p <= 0 { p = 0 }
        if p >= 1 { p = 1 }
        
        var fromR, fromG, fromB, fromA: CGFloat
        fromR = 0; fromG = 0; fromB = 0; fromA = 0
        self.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        
        var toR, toG, toB, toA: CGFloat
        toR = 0; toG = 0; toB = 0; toA = 0
        color.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
        
        let R = fromR * 255 - (fromR - toR) * 255 * p
        let G = fromG * 255 - (fromG - toG) * 255 * p
        let B = fromB * 255 - (fromB - toB) * 255 * p
        let A = fromA - (fromA - toA) * p
        
        return UIColor.init(r: R, g: G, b: B, a: A)
    }
    
}

public extension CGColor {
    
    static func color(_ uiColor: UIColor, alpha: CGFloat = 1.0) -> CGColor {
        uiColor.alpha(alpha).cgColor
    }
    
}

public extension UIColor {
    
    static func gradient(size: CGSize, colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint) -> UIColor? {
        
        let rect: CGRect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        guard let gradientRef = CGGradient(colorsSpace: colorSpaceRef, colors: colors as CFArray, locations: nil) else { return nil }
        let _sPoint = CGPoint(x: startPoint.x * size.width, y: startPoint.y * size.height)
        let _ePoint = CGPoint(x: endPoint.x * size.width, y: endPoint.y * size.height)
        context.drawLinearGradient(gradientRef, start: _sPoint, end: _ePoint, options: [CGGradientDrawingOptions.drawsBeforeStartLocation, CGGradientDrawingOptions.drawsAfterEndLocation])
        defer {
            UIGraphicsEndImageContext()
        }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        return UIColor(patternImage: image)
    }
    
}
