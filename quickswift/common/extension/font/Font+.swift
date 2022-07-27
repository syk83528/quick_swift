//
// Created by Wildog on 12/28/19.
// Copyright (c) 2019 Wildog. All rights reserved.
//

import UIKit

public extension UIFont {
    
    static func regular(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func medium(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .bold)
    }

    static func semibold(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func heavy(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .heavy)
    }

    static func light(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .light)
    }
    
}
