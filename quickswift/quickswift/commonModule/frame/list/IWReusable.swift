//  Created by iWe on 2017/7/24.
//  Copyright © 2017年 iWe. All rights reserved.
//

#if os(iOS)
import UIKit

public enum ReusableSource {
    case cls, nib, storyboard
}

public protocol IWReusable: AnyObject {
    static var identifier: String { get }
    static var reusableSource: ReusableSource? { get }
}

public extension IWReusable {
    static var identifier: String {
        String(describing: self)
    }
    static var reusableSource: ReusableSource? {
        nil
    }
}

public typealias IWNibReusable = IWReusable & IWNibLoadable
#endif
