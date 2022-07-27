//
//  GetProtocol.swift
//  spsd
//
//  Created by suyikun on 2021/12/29.
//  Copyright © 2021 未来. All rights reserved.
//

import Foundation
import UIKit

///// 控制器要遵守的协议
//protocol GetControllerProvider {
//    associatedtype T: GetController
//    var controller: T? { get }
//}

/// controller 要遵守的协议
protocol GetControllerProtocol {
    associatedtype T: AnyObject
    
    var page: T? { get }
    
    static var find: Self? { get }
    
    static func find(_ identify: String?) -> Self?
    
}

extension GetControllerProtocol where Self: GetController {
    
    static var find: Self? {
        Get.find(Self.self)
    }
    
    static func find(_ identify: String? = nil) -> Self? {
        Get.find(Self.self, identify: identify)
    }
    
}
