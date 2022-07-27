//
//  factory+struct.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import UIKit

// MARK: - Make size,rect,point,indexPath,edgeInsets
public func CGSizeMake(_ width: CGFloat, _ height: CGFloat) -> CGSize {
    return CGSize.init(width: width, height: height)
}
public func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect.init(x: x, y: y, width: width, height: height)
}
public func CGPointMake(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
    return CGPoint.init(x: x, y: y)
}

public func MakeSize(_ width: CGFloat, _ height: CGFloat) -> CGSize {
    return CGSize.init(width: width, height: height)
}
public func MakeRect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect.init(x: x, y: y, width: width, height: height)
}
public func MakePoint(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
    return CGPoint.init(x: x, y: y)
}

/// for TableView
public func MakeIndex(row: Int, _ section: Int) -> IndexPath {
    return IndexPath.init(row: row, section: section)
}
/// for CollectionView
public func MakeIndex(item: Int, _ section: Int) -> IndexPath {
    return IndexPath.init(item: item, section: section)
}

public func MakeEdge(t top: CGFloat, l left: CGFloat, b bottom: CGFloat, r right: CGFloat) -> UIEdgeInsets {
    return UIEdgeInsets.init(top: top, left: left, bottom: bottom, right: right)
}
public func MakeEdge(vertical v: CGFloat, horizontal h: CGFloat) -> UIEdgeInsets {
    return UIEdgeInsets(top: v, left: h, bottom: v, right: h)
}
