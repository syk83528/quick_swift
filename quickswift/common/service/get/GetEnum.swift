//
//  GetEnum.swift
//  spsd
//
//  Created by suyikun on 2021/12/29.
//  Copyright © 2021 未来. All rights reserved.
//

import Foundation

public enum GetOperation: Int {
    case ignore
    case replace
}

public enum GetLifeCycle: Int {
    case viewDidLoad
    case viewWillAppear
    case viewDidAppear
    case viewWillDisappear
    case viewDidDisappear
}
