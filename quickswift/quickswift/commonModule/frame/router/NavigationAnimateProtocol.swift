//
//  NavigationAnimateProtocol.swift
//  quick
//
//  Created by suyikun on 2021/7/13.
//

import Foundation

/// 遵循控制器
protocol NavigationControllerProtocol: NSObject {
    var navigationControllerDegate: UINavigationControllerDelegate? { get }
    var navigationOperationType: UINavigationController.Operation { get set }
}
fileprivate var navigationOperationTypeKey: UInt = 0
extension NavigationControllerProtocol {
    var navigationOperationType: UINavigationController.Operation {
        get {
            return objc_getAssociatedObject(self, &navigationOperationTypeKey) as? UINavigationController.Operation ?? .none
        }
        set {
            objc_setAssociatedObject(self, &navigationOperationTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
