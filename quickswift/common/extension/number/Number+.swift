//
//  Number+.swift
//  spsd
//
//  Created by Wildog on 12/28/19.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit

protocol BasicTypeable {
    var string: String { get }
}

extension BasicTypeable {
    var string: String {
        "\(self)"
    }
}

extension CGFloat: BasicTypeable { }
extension Float: BasicTypeable { }
extension Int: BasicTypeable { }

// swiftlint:disable type_name
enum _TupleTransformation {
    case size
    case rect
    case inset
}
// swiftlint:enable type_name

infix operator =>
func => (tuple: (CGFloat, CGFloat), target: _TupleTransformation) -> CGSize {
    CGSize(width: tuple.0, height: tuple.1)
}

// swiftlint:disable large_tuple
func => (tuple: (CGFloat, CGFloat, CGFloat, CGFloat), target: _TupleTransformation) -> CGRect {
    CGRect(x: tuple.0, y: tuple.1, width: tuple.2, height: tuple.3)
}

func => (tuple: (Int, Int, Int, Int), target: _TupleTransformation) -> UIEdgeInsets {
    UIEdgeInsets(top: CGFloat(tuple.0), left: CGFloat(tuple.1), bottom: CGFloat(tuple.2), right: CGFloat(tuple.3))
}
// swiftlint:enable large_tuple

// MARK: - CGFloat
public extension CGFloat {

    var float: Float {
        Float(self)
    }
    
    var int: Int {
        Int(self)
    }
    
    var double: CGFloat {
        self * 2
    }

    static var screenWidth: CGFloat = {
        Screen.width
    }()
    static var screenHeight: CGFloat = {
        Screen.height
    }()

    static var safeAreaTop: CGFloat = {
        Screen.safeArea.top
    }()
    static var safeAreaBottom: CGFloat = {
        Screen.safeArea.bottom
    }()

    static var tabBarHeight: CGFloat = {
        49 + safeAreaBottom
    }()
    static var statusBarHeight: CGFloat = {
        UIApplication.shared.statusBarFrame.height
    }()

    static var navigationBarHeight: CGFloat = {
        44 + statusBarHeight
    }()

    var size: CGSize {
        MakeSize(self, self)
    }

    static let min: CGFloat = .leastNormalMagnitude
    static let max: CGFloat = .greatestFiniteMagnitude

    func min(_ value: CGFloat) -> CGFloat {
        self < value ? value : self
    }
}

// MARK: - Float
public extension Float {

    static let min = Float.leastNormalMagnitude
    static let max = Float.greatestFiniteMagnitude

    var cgFloat: CGFloat {
        CGFloat(self)
    }

    var int: Int {
        Int(self)
    }
    var double: Double {
        Double(self)
    }
    /// (保留两位小数).
    var retain: String {
        String(format: "%.2f", self)
    }
    /// (保留 digit 位小数).
    func retain(_ digit: Int) -> String {
        String(format: "%.\(digit)f", self)
    }
}

// MARK: - Int
public extension Int {

    var float: Float {
        Float(self)
    }
    
    var double: Double {
        Double(self)
    }

    var cgFloat: CGFloat {
        CGFloat(self)
    }
    
    /// (返回一个 0 ..< self 的区间).
    var countableRange: CountableRange<Int> {
        0 ..< self
    }
    /// (返回一个 0 ... self 的区间).
    var closeRange: ClosedRange<Int> {
        0 ... self
    }

    /// (随机取一个从 from - to 之间的数)
    static func random(from: Int = 0, to: Int) -> Int {
        guard from < to else { return 0 }
        return Int(arc4random() % UInt32(to)) + from
    }
    static var random: Int {
        Int(arc4random() % 100) + 1
    }

    /// (是否为质数).
    ///     质数定义为在大于1的自然数中，除了1和它本身以外不再有其他因数。
    var isPrime: Bool {
        if self == 2 { return true }
        guard self > 1, self % 2 != 0 else { return false }

        let base = Int(sqrt(Double(self)))
        for i in Swift.stride(from: 3, through: base, by: 2) where self % i == 0 {
            return false
        }
        return true
    }
}

// MARK: - CGSize/NSSize
public extension CGSize {

    var rect: CGRect {
        CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }

    var bounds: CGRect {
        rect
    }

    static var max: CGSize {
        MakeSize(.max, .max)
    }

    static var screenSize: CGSize = {
        Screen.size
    }()

    /// (是否为空, width<=0 && height<=0 则为空).
    var isZero: Bool {
        isWidthZero && isHeightZero
    }

    /// (value.width <= 0).
    var isWidthZero: Bool {
        self.width <= 0
    }

    /// (value.height <= 0).
    var isHeightZero: Bool {
        self.height <= 0
    }

    static func > (lft: CGSize, rlt: CGFloat) -> Bool {
        lft.width > rlt && lft.height > rlt
    }
    static func < (lft: CGSize, rlt: CGFloat) -> Bool {
        lft.width < rlt && lft.height < rlt
    }
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        MakeSize(lhs.width * rhs, lhs.height * rhs)
    }
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        MakeSize(lhs.width + rhs.width, lhs.height + rhs.height)
    }
}

public extension CGRect {

    static var screenBounds: CGRect = {
        Screen.bounds
    }()

    var x: CGFloat {
        get { self.minX }
        set { self.origin.x = newValue }
    }
    var y: CGFloat {
        get { self.minY }
        set { self.origin.y = newValue }
    }
    var width: CGFloat {
        get { self.size.width }
        set { self.size.width = newValue }
    }
    var height: CGFloat {
        get { self.size.height }
        set { self.size.height = newValue }
    }
    
    @discardableResult
    func move(x: CGFloat) -> CGRect {
        var rect = self
        rect.x += x
        return rect
    }
    @discardableResult
    func move(y: CGFloat) -> CGRect {
        var rect = self
        rect.y += y
        return rect
    }
    @discardableResult
    func move(width: CGFloat) -> CGRect {
        var rect = self
        rect.width += width
        return rect
    }
    
    @discardableResult
    func move(height: CGFloat) -> CGRect {
        var rect = self
        rect.height += height
        return rect
    }
    @discardableResult
    func set(width: CGFloat) -> CGRect {
        var rect = self
        rect.width = width
        return rect
    }
    @discardableResult
    func set(height: CGFloat) -> CGRect {
        var rect = self
        rect.height = height
        return rect
    }
}

// MARK: - Bool
public extension Bool {

    var isFalse: Bool {
        self == false
    }

    /// (随机一个 ture or false)
    static var random: Bool {
        arc4random_uniform(2) == 1
    }

    /// (Returns !self)
    var inversed: Bool {
        !self
    }
    
    var int: Int {
        self == true ? 1 : 0
    }

    /// (bool = true).
    mutating func enable() {
        self = true
    }
    /// (bool = false).
    mutating func disable() {
        self = false
    }
}

// MARK: - SingedInteger
extension SignedInteger {

    /// (取绝对值).
    var abs: Self { Swift.abs(self) }
    /// (是否为正数, int > 0).
    var isPositive: Bool { self > 0 }
    /// (是否为负数, int < 0).
    var isNegative: Bool { self < 0 }
    /// (是否为偶数, (int % 2) == 0).
    var isEven: Bool { (self % 2) == 0 }
    /// (是否为奇数, (int % 2) != 0).
    var isOdd: Bool { (self % 2) != 0 }
    /// (Bool, value > 0?).
    var bool: Bool {
        self > 0
    }

//    func formatTime(_ style: Date.FormatKind = .natural()) -> String {
//        return Date.format(Double(self) / 1000.0, style: style)
//    }

    var size: CGSize {
        let wh = CGFloat(Int(self))
        return CGSize(width: wh, height: wh)
    }
}

// MARK: - FloatingPoint
public extension FloatingPoint {

    /// (取绝对值).
    var abs: Self { Swift.abs(self) }
    /// (是否为正数).
    var isPositive: Bool { self > 0 }
    /// (是否为负数).
    var isNegative: Bool { self < 0 }
    /// (向上取整).
    var ceil: Self { Foundation.ceil(self) }
    /// (向下取整).
    var floor: Self { Foundation.floor(self) }

}

// MARK: - Double
public extension Double {

    var int: Int {
        Int(self)
    }
    var float: Float {
        Float(self)
    }
    var cgFloat: CGFloat {
        CGFloat(self)
    }
    
    var interval: TimeInterval {
        TimeInterval(self)
    }

    var string: String {
        "\(self)"
    }
    /// (保留两位小数).
    var retain: String {
        String(format: "%.2f", self)
    }
    /// (保留 digit 位小数).
    func retain(_ digit: Int) -> String {
        String(format: "%.\(digit)f", self)
    }

    func ignoreNaN(defaultValue: Double = 1) -> Double {
        isNaN ? defaultValue : self
    }
}

public extension UIEdgeInsets {

    static func != (lft: UIEdgeInsets, rlt: UIEdgeInsets) -> Bool {
        return lft.top != rlt.top || lft.bottom != rlt.bottom || lft.right != rlt.right || lft.left != rlt.left
    }
    
    init(top: CGFloat? = 0, left: CGFloat? = 0, bottom: CGFloat? = 0, right: CGFloat? = 0) {
        self = UIEdgeInsets(top: top ?? 0, left: left ?? 0, bottom: bottom ?? 0, right: right ?? 0)
    }
    
    static func top(_ top: CGFloat) -> UIEdgeInsets {
        .init(top: top, left: 0, bottom: 0, right: 0)
    }
    static func left(_ left: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: left, bottom: 0, right: 0)
    }
    static func bottom(_ bottom: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: 0, bottom: bottom, right: 0)
    }
    static func right(_ right: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: 0, bottom: 0, right: right)
    }
    
    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: value, left: 0, bottom: value, right: 0)
    }
    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: value, bottom: 0, right: value)
    }
}

public extension CGPoint {
    static func + (point: CGPoint, offset: CGPoint) -> CGPoint {
        CGPoint(x: point.x + offset.x, y: point.y + offset.y)
    }
    
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
    }
}

public extension CGSize {
    var isPortrait: Bool {
        width < height
    }
    
    func restrict(width: CGFloat) -> CGSize {
        guard self.width > 0 && self.height > 0 else { return CGSize(width: width, height: width) }
        if self.width > width {
            return CGSize(width: width, height: self.height / self.width * width)
        }
        return self
    }
    
    func restrict(height: CGFloat) -> CGSize {
        guard self.width > 0 && self.height > 0 else { return CGSize(width: height, height: height) }
        if self.height > height {
            return CGSize(width: self.width / self.height * height, height: self.height)
        }
        return self
    }
    
    func restrict(_ maxSide: CGFloat, maxRatio: CGFloat = 3, extendMaxSide: Bool = false) -> CGSize {
        guard width > 0 && height > 0 else { return CGSize(width: maxSide, height: maxSide) }
        var maxSide = maxSide
        if extendMaxSide, height / width >= 2.5 {
            maxSide = height / width * 0.6 * maxSide
        }
        var targetWidth: CGFloat
        var targetHeight: CGFloat
        if width > height {
            targetWidth = width > maxSide ? maxSide : width
            targetHeight = targetWidth * height / width
        } else {
            targetHeight = height > maxSide ? maxSide : height
            targetWidth = targetHeight * width / height
            if maxRatio > 0, maxRatio < .max {
                let minSide = maxSide / maxRatio
                if targetWidth < minSide {
                    targetWidth = minSide
                }
            }
        }
        return CGSize(width: targetWidth, height: targetHeight)
    }
    
    func toString(separator: String = ",", precision: Int = 0) -> String {
        String(format: "%.\(precision)f\(separator)%.\(precision)f", width, height)
    }
}

public extension CGFloat {
    func roundTo(precision: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(precision))
        return (self * divisor).rounded()
    }
}

public extension Double {
    func roundTo(precision: Int) -> Double {
        let divisor = pow(10.0, Double(precision))
        return (self * divisor).rounded()
    }
}

public extension Float {
    func roundTo(precision: Int) -> Float {
        let divisor = pow(10.0, Float(precision))
        return (self * divisor).rounded()
    }
}

public extension TimeInterval {
    enum FormatStyle: Int {
        case duration
    }
    
    func format(_ style: FormatStyle) -> String {
        switch style {
        case .duration:
            let timeInterval = floor
            let hours = Int(timeInterval) / 3600
            
            let formatter = DateComponentsFormatter().then {
                $0.zeroFormattingBehavior = .pad
                $0.allowedUnits = [.hour, .minute, .second]
            }
            if hours > 0 {
                formatter.allowedUnits = [.hour, .minute, .second]
            } else {
                formatter.allowedUnits = [.minute, .second]
            }
            
            return formatter.string(from: timeInterval) ?? ""
        }
    }
}

extension NSNull {
    @objc func _fastCStringContents(_ value: Int8) -> UnsafePointer<Int8>? {
        nil
    }
    
    @objc func _fastCharacterContents() -> UnsafePointer<UInt16>? {
        nil
    }
}
