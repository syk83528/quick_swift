//
//  ClickTroughView.swift
//  spsd
//
//  Created by Wildog on 1/2/20.
//  Copyright © 2020 Wildog. All rights reserved.
//

import UIKit

open class PointInsideOnDemandView: UIView {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews.reversed() {
            guard !view.isHidden, view.alpha > 0, view.isUserInteractionEnabled,
                view.frame.contains(point) else {
                continue
            }
            if view is PointInsideOnDemandView {
                let innerPoint = convert(point, to: view)
                return view.point(inside: innerPoint, with: event)
            }
            return true
        }
        return false
    }
}

open class ClickThroughView: PointInsideOnDemandView {
    open var ignoreSubviews: Bool = false
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden {
            return nil
        }
        if self.ignoreSubviews {
            return super.hitTest(point, with: event)
        }
        for view in subviews.reversed() {
            guard !view.isHidden,
                  view.alpha > 0,
                  view.isUserInteractionEnabled,
                  view.frame.contains(point)
            else {
                    continue
            }
            let innerPoint = convert(point, to: view)
            if view is ClickThroughView {
                if let target = view.hitTest(innerPoint, with: event) {
                    return target
                }
            } else {
                return view.hitTest(innerPoint, with: event)
            }
        }
        return nil
    }
}
