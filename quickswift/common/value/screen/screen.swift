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


public struct ScreenUtilInit {
    /// 设计图上按什么机型设计 这里就初始化成什么大小
    public static var desizeSize: CGSize = MakeSize(375, 667)
}

public extension CGFloat {
    public var w: CGFloat {
        self / ScreenUtilInit.desizeSize.width * UIScreen.main.bounds.size.width
    }
    
    public var h: CGFloat {
        self / ScreenUtilInit.desizeSize.height * UIScreen.main.bounds.size.width
    }
}

public extension Int {
    var w: CGFloat {
        CGFloat(self) / ScreenUtilInit.desizeSize.width * UIScreen.main.bounds.size.width
    }
    
    var h: CGFloat {
        CGFloat(self) / ScreenUtilInit.desizeSize.height * UIScreen.main.bounds.size.width
    }
}

public extension Double {
    var w: CGFloat {
        CGFloat(self) / ScreenUtilInit.desizeSize.width * UIScreen.main.bounds.size.width
    }
    
    var h: CGFloat {
        CGFloat(self) / ScreenUtilInit.desizeSize.height * UIScreen.main.bounds.size.width
    }
}

public extension Int64 {
    var w: CGFloat {
        CGFloat(self) / ScreenUtilInit.desizeSize.width * UIScreen.main.bounds.size.width
    }
    
    var h: CGFloat {
        CGFloat(self) / ScreenUtilInit.desizeSize.height * UIScreen.main.bounds.size.width
    }
}
