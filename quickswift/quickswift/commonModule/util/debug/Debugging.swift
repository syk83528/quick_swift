//
//  Debugging.swift
//  quick
//
//  Created by suyikun on 2021/6/18.
//

import Foundation
#if DEBUG
private let dateFormatter = DateFormatter().then {
    $0.dateFormat = "[dd/MM/yyyy HH:mm:ss.SSS]"
    $0.locale = Locale(identifier: "en_US_POSIX")
}
#endif

#if DEBUG
private let logFilter: [String] = []

private func check(_ items: [Any], containsAnyOf: [String]) -> Bool {
    for item in items {
        if let string = item as? String {
            for filter in logFilter {
                if string.contains(filter) {
                    return true
                }
            }
        } else if let array = item as? [Any] {
            if check(array, containsAnyOf: containsAnyOf) {
                return true
            }
        }
    }
    return false
}

#endif

func log(_ items: Any?..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    
    if logFilter.count > 0, !check(items.map({ (item) -> Any in
        if let item = item {
            return item
        }
        return "\(type(of: item)): nil" as Any
    }), containsAnyOf: logFilter) {
        return
    }

    Swift.print(dateFormatter.string(from: Date()), terminator: separator)

    var idx = items.startIndex
    let endIdx = items.endIndex

    repeat {
        let item = items[idx]
        if item is Error {
            Swift.print(item.debugDescription, separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
        } else {
            Swift.print(item ?? "\(type(of: item)): nil", separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
        }
        idx += 1
    }
    while idx < endIdx
    #endif
}

func errors(_ desc: Any?...) {
    #if DEBUG
    let array = desc.map({ (item) -> Any in
        if let item = item {
            return item
        }
        return "\(type(of: item)): nil" as Any
    })
    let text = "❌ \(array)"
    log(text)
//    DebugLog.shared.inputText(text + "\n")
    #endif
}

func warning(_ desc: Any?...) {
    #if DEBUG
    let array = desc.map({ (item) -> Any in
        if let item = item {
            return item
        }
        return "\(type(of: item)): nil" as Any
    })
    let text = "⚠️ \(array)"
    log(text)
//    DebugLog.shared.inputText(text + "\n")
    #endif
}

func dealog(_ desc: Any?...) {
    #if DEBUG
    let array = desc.map({ (item) -> Any in
        if let item = item {
            return item
        }
        return "\(type(of: item)): nil" as Any
    })
    let text = "【☺️】 \(array) deinit."
    log(text)
//    DebugLog.shared.inputText(text + "\n")
    #endif
}
