//
//  TrimProperty.swift
//  quick
//
//  Created by suyikun on 2021/6/27.
//

import Foundation

@propertyWrapper
class TrimProperty {
    
    private var value: String
    
    init(wrappedValue: String) {
        value = wrappedValue
    }
    
    var wrappedValue: String {
        get {
            value
        }
        set {
            value = newValue
        }
    }
}
