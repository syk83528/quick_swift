//
//  window_validation.swift
//  quickswift
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import common

protocol WindowValidation {
    var isValid: Bool { get }
}

extension WindowValidation where Self: UIWindow {
    var isValid: Bool {
        isHidden && isUserInteractionEnabled
    }
}

extension UIWindow {
    static var customBounds: CGRect { // 高度 + 1
        var bounds = Screen.bounds
        bounds.height += 1
        return bounds
    }
}
