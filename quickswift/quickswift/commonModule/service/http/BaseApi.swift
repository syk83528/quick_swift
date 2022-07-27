//
//  BaseApi.swift
//  spsd
//
//  Created by suyikun on 2021/9/28.
//  Copyright © 2021 未来. All rights reserved.
//

import Foundation

class BaseApi: APIService {
    private let routePath: APIRoute
    private var params: (() -> APIParameters?)?

    init(
        path: APIRoute,
        params: (() -> APIParameters?)? = nil
    ) {
        self.routePath = path
        self.params = params
    }

    var servicePath: String {
        ""
    }

    var version: String? {
        ""
    }

    var route: APIRoute {
        routePath
    }

    var parameters: APIParameters? {
        params?()
    }
}
