//
//  array+handyjson.swift
//  common
//
//  Created by suyikun on 2022/7/28.
//

import Foundation
import HandyJSON

extension Array where Element: HandyJSON {
    
    @discardableResult
    func mapIndex(to key: String) -> [Element] {
        for (idx, e) in self.enumerated() {
            var _e = e
            JSONDeserializer.update(object: &_e, from: [key: idx])
        }
        return self
    }
    
    @discardableResult
    func mapSetValue(for key: String, value: Any?) -> [Element] {
        for e in self {
            var _e = e
            JSONDeserializer.update(object: &_e, from: [key: value as Any])
        }
        return self
    }
}
