//
//  View+Shimmer.swift
//  spsd
//
//  Created by suyikun on 2021/11/24.
//  Copyright © 2021 未来. All rights reserved.
//

import Foundation
import UIKit

private let containerTag = 7774
extension UIView {
    
    func addShimmer(_ cornerRadius: CGFloat? = nil) {
        defer {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        self.r.trigger(for: #selector(layoutSubviews)).take(first: 1).observeValues { [weak self] _ in
            guard let self = self else { return }
            let animationSize = self.bounds.size
            
            commonllog("~~~~~animationSize\(animationSize)")
             // 移除old
            self.viewWithTag(containerTag)?.removeFromSuperview()
            
            // 添加一个容器视图
            let maskContainer = UIView().then {
                $0.tag = containerTag
                $0.layer.cornerRadius = cornerRadius ?? animationSize.height / 2 // 切个圆角效果
                $0.clipsToBounds = true
                $0.backgroundColor = .white.alpha(0.5)
                $0.add(to: self)
                $0.isUserInteractionEnabled = false
                $0.snp.remakeConstraints { make in
                    make.top.left.right.bottom.equalToSuperview()
                }
            }
            
            // 准备一个渐变
            let gradientLayer = CAGradientLayer().then {
                let light = UIColor.red.withAlphaComponent(1).cgColor
                let alpha = UIColor.red.withAlphaComponent(0).cgColor
                $0.colors = [alpha, light, alpha]
                $0.frame = CGRect(x: -animationSize.width, y: 0, width: animationSize.width  * 3, height: animationSize.height)
                $0.startPoint = CGPoint(x: 0, y: 0.5)
                $0.endPoint = CGPoint(x: 1.0, y: 0.58)
                $0.locations = [0.45, 0.5, 0.55]
            }
            
            // 准备一个动画
            let gradientAnimation = CABasicAnimation(keyPath: "locations").then {
                $0.fromValue = [0.0, 0.05, 0.1]
                $0.toValue = [0.9, 0.95, 1.0]
                $0.duration = 1.5
                $0.repeatCount = Float.max
                $0.isRemovedOnCompletion = false
            }
            maskContainer.layer.mask = gradientLayer
            gradientLayer.add(gradientAnimation, forKey: "shimmer")
        }
        
    }
    
    func removeShimmer() {
       self.viewWithTag(containerTag)?.removeFromSuperview()
    }
    
    
    
}

extension CALayer {
    
    class func shimmerLayer(_ size: CGSize, color: UIColor = .white, repeat count: Float = .max) -> CAGradientLayer {
        let colorLayer = CAGradientLayer().then {
            $0.frame = CGRect(origin: .zero, size: size)
            $0.colors = [color.withAlphaComponent(0).cgColor,
                         color.withAlphaComponent(0.6).cgColor,
                         color.withAlphaComponent(0).cgColor]
            $0.locations = [0.4, 0.5, 0.6]
            $0.startPoint = CGPoint(x: 0, y: 0)
            $0.endPoint = CGPoint(x: 1, y: 1)
        }
        let fadeAnimation = CABasicAnimation(keyPath: "locations").then {
            $0.fromValue = [0.0, 0.1, 0.2]
            $0.toValue = [0.8, 0.9, 1.0]
            $0.duration = 1.5
            $0.repeatCount = count
             $0.isRemovedOnCompletion = false
        }
        colorLayer.add(fadeAnimation, forKey: "fadeAnimation")
        return colorLayer
    }
    
}
