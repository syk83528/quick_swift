//  Created by iWe on 2017/9/6.
//  Copyright © 2017年 iWe. All rights reserved.
//

#if os(iOS)
import UIKit

public protocol IWNibLoadable: AnyObject {
    /// (返回 UINib).
    static var nib: UINib { get }
}

public extension IWNibLoadable {
    
    /// (返回 UINib).
    static var nib: UINib {
        UINib(nibName: nibName, bundle: nibBundle)
    }

    static var nibName: String {
        String(describing: self)
    }

    static var nibBundle: Bundle {
        Bundle(for: self)
    }
}

public extension IWNibLoadable where Self: UIView {
    
    /// (从 xib 加载 view).
    static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
}

#endif
