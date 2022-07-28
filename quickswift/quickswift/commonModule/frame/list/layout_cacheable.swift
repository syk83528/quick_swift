//
//  layout_cacheable.swift
//  quickswift
//
//  Created by suyikun on 2022/7/28.
//

import Foundation
import UIKit
import HandyJSON
import IGListDiffKit

public typealias DiffableJSON = HandyJSON & ListDiffable

protocol LayoutCachable {
    static var cellHeight: CGFloat { get }
    static var cellSize: CGSize { get }
    var cellHeight: CGFloat { get }
    var cellSize: CGSize { get }
}

extension LayoutCachable {
    static var cellHeight: CGFloat { 0 }
    static var cellSize: CGSize { .zero }
    var cellHeight: CGFloat { Self.cellHeight }
    var cellSize: CGSize { Self.cellSize }
}
