//
//  screen.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import UIKit

public struct Screen {
    private init() { }
    
    public static let bounds = UIScreen.main.bounds
    public static let size = Screen.bounds.size
    public static let width = Screen.size.width
    public static let height = Screen.size.height
    /// 纵横比
    public static let aspectRatio = Screen.height / Screen.width
    
    public static let scale = UIScreen.main.scale
    
    public static var safeArea: UIEdgeInsets = {
        if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.delegate?.window {
                return window!.safeAreaInsets
            }
        }
        return .zero
    }()
    
    public static var navigationHeight: CGFloat = {
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.delegate?.window {
                return window!.safeAreaInsets.top + 44
            }
        }
        return 20 + 44
    }()
}
