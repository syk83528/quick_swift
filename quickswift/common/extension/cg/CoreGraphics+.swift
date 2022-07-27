//
//  CoreGraphics+.swift
//  spsd
//
//  Created by JunFly on 2021/8/11.
//  Copyright © 2021 未来. All rights reserved.
//

import Foundation

// 创建 自定义圆角半径的圆 路径
public extension CGPath {
    
    struct CornerRadii {
        var topLeft: CGFloat
        var topRight: CGFloat
        var bottomLeft: CGFloat
        var bottomRight: CGFloat
    }
    
    // 自定义各个圆角路径
    static func rounded(rect: CGRect, cornerRadii: CornerRadii) -> CGPath {
        
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        
        let topLeftCenter = CGPoint(x: minX + cornerRadii.topLeft, y: minY + cornerRadii.topLeft)
        let topRightCenter = CGPoint(x: maxX - cornerRadii.topRight, y: minY + cornerRadii.topRight)
        let bottomLeftCenter = CGPoint(x: minX + cornerRadii.bottomLeft, y: maxY - cornerRadii.bottomLeft)
        let bottomRightCenter = CGPoint(x: maxX - cornerRadii.bottomRight, y: maxY - cornerRadii.bottomRight)
        
        let radian0: CGFloat = 0
        let radian90: CGFloat = .pi / 2
        let radian180: CGFloat = .pi
        let radian270: CGFloat = .pi * 3 / 2
        
        let path = CGMutablePath()
        
        path.addArc(center: topLeftCenter, radius: cornerRadii.topLeft, startAngle: radian180, endAngle: radian270, clockwise: false)
        
        path.addArc(center: topRightCenter, radius: cornerRadii.topRight, startAngle: radian270, endAngle: radian0, clockwise: false)
        
        path.addArc(center: bottomRightCenter, radius: cornerRadii.bottomRight, startAngle: radian0, endAngle: radian90, clockwise: false)
        
        path.addArc(center: bottomLeftCenter, radius: cornerRadii.bottomLeft, startAngle: radian90, endAngle: radian180, clockwise: false)
        
        path.closeSubpath()
        
        return path
    }
    
    
}
