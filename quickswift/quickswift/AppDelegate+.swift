//
//  AppDelegate+.swift
//  quick
//
//  Created by suyikun on 2021/6/21.
//

import Foundation

extension AppDelegate {
    func prepareRootController(firstLaunch: Bool = false) {
        guard let window = self.window else { return }
        for delegate in Self.delegates {
            if let rootProvider = delegate as? RootProviderProtocol {
                if rootProvider.provide(for: window, firstLaunch: firstLaunch) {
                    return
                }
            }
        }
    }
}
