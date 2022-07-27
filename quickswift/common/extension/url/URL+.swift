//
//  URL+.swift
//  IWBaseKits
//
//  Created by 未来 on 2019/4/3.
//  Copyright © 2019 iWECon. All rights reserved.
//

#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

public extension URL {
    
    var params: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else { return nil }
        
        var items: [String: String] = [:]
        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }
        return items
    }
    
}

public extension URL {
    
    /// (添加参数到链接后).
    ///
    ///     let url = URL(string: "https://www.google.com")!
    ///     let param = ["q": "question"]
    ///     url.append(params: param) -> "https://google.com?q=question"
    func append(params parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var items = urlComponents.queryItems ?? []
        items += parameters.map({ URLQueryItem(name: $0, value: $1) })
        urlComponents.queryItems = items
        return urlComponents.url!
    }
    
}

public extension URLComponents {
    
    @discardableResult
    mutating func appendQuery(_ name: String, value: String?) -> Self {
        var items = queryItems ?? []
        if let i = items.firstIndex(where: { $0.name == name }) {
            items[i].value = value
        } else {
            items.append(.init(name: name, value: value))
        }
        self.queryItems = items
        return self
    }
    
    @discardableResult
    mutating func appendQuery(_ parameters: [String: String]) -> Self {
        var items = queryItems ?? []
        items += parameters.map({ URLQueryItem(name: $0, value: $1) })
        self.queryItems = items
        return self
    }
    
    var isHttpScheme: Bool {
        guard let scheme = scheme else {
            return false
        }
        return scheme == "http" || scheme == "https"
    }
    
}
