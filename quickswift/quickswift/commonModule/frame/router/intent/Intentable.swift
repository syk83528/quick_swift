//
//  Intentable.swift
//  quick
//
//  Created by suyikun on 2021/6/26.
//

import Foundation
import UIKit
import common

protocol Intentable {
    func intentValue() -> Any
}

@propertyWrapper
class IntentProperty<T>:Intentable {
    
    private var value: T
    
    init(wrappedValue: T) {
        value = wrappedValue
    }
    
    var wrappedValue: T {
        get {
            value
        }
        set {
            value = newValue
        }
    }
    
    func intentValue() -> Any {
        value
    }
}

extension UIViewController {
    
func intentValue(for intents: [String]? = nil) -> Dict {
    if let intents = intents {// 手动传值
        let mirror = Mirror(reflecting: self)
        
        var intentDict = Dict()
        for child in mirror.children {
            let label = child.label ?? ""
            guard intents.contains(label) else { continue }
            intentDict[label] = child.value
        }
        log(intentDict)
        return intentDict
    } else { // propertyWrapper
        let mirror = Mirror(reflecting: self)
        
        var intentDict = Dict()
        for child in mirror.children {
            guard let intent = child.value as? Intentable else { continue }
            let label = child.label?.substring(fromIndex: 1) ?? ""
            let intentValue = intent.intentValue()
            intentDict[label] = intentValue
        }
        log(intentDict)
        return intentDict
    }
}
}
