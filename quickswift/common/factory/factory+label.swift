//
//  factory+label.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import UIKit

public func buildLabel(
    text: String? = nil,
    font: UIFont? = nil,
    color: UIColor? = nil,
    alignment: NSTextAlignment? = nil,
    numberOfLines: Int? = nil
) -> UILabel {
    let v = UILabel()
    if let text = text { v.text = text }
    if let font = font { v.font = font }
    if let color = color { v.textColor = color }
    if let alignment = alignment { v.textAlignment = alignment }
    if let numberOfLines = numberOfLines { v.numberOfLines = numberOfLines }
    return v
}
