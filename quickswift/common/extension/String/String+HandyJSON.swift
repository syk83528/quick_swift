//
//  String+HandyJSON.swift
//  spsd
//
//  Created by iWw on 2022/1/21.
//  Copyright © 2022 未来. All rights reserved.
//

import UIKit
import HandyJSON

extension String: HandyJSONCustomTransformable {
    
    public static func _transform(from object: Any) -> String? {
        return "\(object)".replace("Optional(", to: "").replace(")", to: "")
    }
    public func _plainValue() -> Any? {
        return self
    }
    
}
