//
//  View+Animation.swift
//  spsd
//
//  Created by suyikun on 2020/11/26.
//  Copyright © 2020 未来. All rights reserved.
//

import UIKit

extension CALayer {
    func addMask(_ corners: UIRectCorner = .allCorners, cornerRadii: CGSize) {
        let path = UIBezierPath(roundedRect: MakeRect(0, 0, self.frame.size.width, self.frame.size.height), byRoundingCorners: corners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.mask = maskLayer
    }
}

extension UIView {
    public enum ShakeDirection {
       case horizontal
       case vertical
    }
    /// 抖动动画  提示输入啥的
    public func shake(_ times: Int = 5, shakeDirection: ShakeDirection = .horizontal) {
        let anim = CAKeyframeAnimation(keyPath: "transform")
        switch shakeDirection {
        case .horizontal:
            anim.values = [
                NSValue(caTransform3D: CATransform3DMakeTranslation(-5, 0, 0 )),
                NSValue(caTransform3D: CATransform3DMakeTranslation( 5, 0, 0 ))]
        case .vertical:
            anim.values = [
                NSValue(caTransform3D: CATransform3DMakeTranslation( 0, -5, 0 )),
                NSValue(caTransform3D: CATransform3DMakeTranslation( 0, 5, 0 ))]
        }
        anim.autoreverses = true
        anim.repeatCount = Float(times)
        anim.duration = 0.03

        self.layer.add(anim, forKey: nil)
    }
    
    // 放大缩小动画
    func scaleAnimation(scaleAry: [CGFloat], duration: CFTimeInterval = 1.2, keytimes: [NSNumber]) {
        
        let animation = CAKeyframeAnimation(keyPath: "transform")
        
        var valueAry: [Any] = [Any]()
        for scale in scaleAry {
            let scale0 = CATransform3DMakeScale(scale, scale, 1)
            valueAry.append(scale0)
        }
        animation.values = valueAry
        animation.duration = duration
        animation.keyTimes = keytimes
        animation.calculationMode = .linear
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.repeatCount = Float.max
        self.layer.add(animation, forKey: "animation")

    }
}
