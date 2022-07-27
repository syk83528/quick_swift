//
//  impacter.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation

public struct Impacter {
    private init() {}
    
    public static let light: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light).then {
        $0.prepare()
    }
    
    public static let normal: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium).then {
        $0.prepare()
    }
    
    public static let heavy: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy).then {
        $0.prepare()
    }
}
