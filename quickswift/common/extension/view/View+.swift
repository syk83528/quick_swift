//
//  Created by 未来 on 2019/4/3.
//  Copyright © 2019 iWECon. All rights reserved.
//

#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

import FlexLayout
import SnapKit
import PinLayout

public extension UIView {
    
    var x: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    var y: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    
    var width: CGFloat {
        get { return self.frame.width }
        set { self.frame.size.width = newValue }
    }
    var height: CGFloat {
        get { return self.frame.height }
        set { self.frame.size.height = newValue }
    }
    
    var size: CGSize {
        get { return self.frame.size }
        set { self.frame.size = newValue }
    }
    var sizeSideLength: CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size = .init(width: newValue, height: newValue) }
    }
    
    var origin: CGPoint {
        get { return self.frame.origin }
        set { self.frame.origin = newValue }
    }
    
    var left: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    var right: CGFloat {
        get { return self.frame.origin.x + self.frame.size.width }
        set { self.frame.origin.x = newValue - self.frame.size.width }
    }
    
    /// (视图右边距离 superView 右边的距离).
    var insetRight: CGFloat {
        get {
            guard let sv = self.superview else { return self.right }
            return sv.width - self.right }
        set {
            guard let sv = self.superview else { self.right = 0; return }
            self.right = sv.width - newValue }
    }
    
    var top: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    var bottom: CGFloat {
        get { return self.frame.origin.y + self.frame.size.height }
        set { self.frame.origin.y = newValue - self.frame.size.height }
    }
    var centerX: CGFloat {
        get { return self.frame.midX }
        set { self.frame.origin.x = newValue - self.width / 2 }
    }
    var centerY: CGFloat {
        get { return self.frame.midY }
        set { self.frame.origin.y = newValue - self.height / 2 }
    }
    
}

// MARK: - Wrap
extension UIView {
    @discardableResult
    func wrapView(size: CGSize, autoLayout: Bool = true) -> UIView {
        let v = UIView()
        v.size = size
        v.backgroundColor = .clear
        v.addSubview(self)
        if autoLayout {
            v.snp.makeConstraints { (maker) in
                maker.size.equalTo(size)
            }
            self.snp.makeConstraints { (maker) in
                maker.centerY.equalTo(v)
                maker.width.equalTo(v)
            }
        }
        return v
    }
    
//    @discardableResult
//    func wrapClickThrough() -> ClickThroughView {
//        let click = ClickThroughView()
//        click.addSubview(self)
//        click.backgroundColor = .clear
//        snp.makeConstraints { (maker) in
//            maker.edges.equalToSuperview()
//        }
//        return click
//    }
    
    var barButtonItem: UIBarButtonItem {
        var containerSize = self.size
        if containerSize.width <= 0 {
            self.sizeToFit()
            containerSize.width = self.size.width
        }
        if containerSize.height < 44 {
            containerSize.height = 44
        }
        return UIBarButtonItem(customView: wrapView(size: containerSize))
    }
}

public extension UIView {
    
    func visible(when: @autoclosure () -> Bool) {
        isHidden = !when()
    }
    
    /// 移除所有子视图
    func removeAllSubviews() {
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
    }

    /// 生成 line 并添加
    func draw(line frame: CGRect, color: UIColor = .init(hex: 0xdedede)) -> UIView {
        let line = UIView.init(frame: frame)
        line.backgroundColor = color
        self.addSubview(line)
        return line
    }
    
    @discardableResult
    func add(to: UIView) -> Self {
        to.addSubview(self)
        return self
    }
    
    func addSubview(_ views: UIView...) {
        views.forEach({ self.addSubview($0) })
    }
    
    func shadow(_ color: UIColor = UIColor.black.alpha(0.1), opacity: CGFloat = 1.0, radius: CGFloat = 15, offset: CGSize = .zero) {
        layer.shadowRadius = radius
        layer.shadowOpacity = 1
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
    
    func hideSelf() {
        isHidden = true
    }
    func showSelf() {
        isHidden = false
    }
    /// 是否展示(isHidden判断逻辑多一层,写代码方便点)
    var isVisible: Bool {
        get {
            return !self.isHidden
        }
        set {
            self.isHidden = !newValue
        }
    }
    /// 设置锚点(如无特殊要求，动画完成记得重置回到(0.5, 0.5)，否则整体布局会乱七八糟)
    func setAnchorPoint(anchorPoint: CGPoint) {
        let oldOrigin = self.frame.origin
        self.layer.anchorPoint = anchorPoint
        let newOrigin = self.frame.origin
        
        var transition: CGPoint = .zero
        transition.x = newOrigin.x - oldOrigin.x
        transition.y = newOrigin.y - oldOrigin.y
    
        self.center = CGPoint(x: self.center.x - transition.x, y: self.center.y - transition.y)
    }
}
public extension UIView {
    /// 所有子视图带颜色 ,布局用
    func makeSubColors() {
        if self.subviews.count > 0 {
            for sub in self.subviews {
                sub.makeSubColors()
            }
        } else {
            self.backgroundColor = UIColor.randomWithLight
        }
    }
}

public extension UIView {
    
    static var xibViews: [Any]? {
        let path = _xibPath()
        if path != nil {
            let className = String(describing: self)
            // Bundle.main.loadNibNamed(<#T##name: String##String#>, owner: <#T##Any?#>, options: <#T##[UINib.OptionsKey : Any]?#>)
            let nibs = UINib(nibName: className, bundle: nil).instantiate(withOwner: 0, options: nil)
            return nibs
        }
        return nil
    }
    
    private class func _xibPath() -> String? {
        let className = String(describing: self)
        let path = Bundle.main.path(forResource: className, ofType: ".nib")
        guard let filePath = path else { return nil }
        if FileManager.default.fileExists(atPath: filePath) { return filePath }
        
        return nil
    }
}

// MARK: - move view's zPosition
public extension UIView {
    func above(to: UIView?) {
        guard let to = to, to.superview == superview else { return }
        superview?.insertSubview(self, aboveSubview: to)
    }
    func below(to: UIView?) {
        guard let to = to, to.superview == superview else { return }
        superview?.insertSubview(self, belowSubview: to)
    }
    func move(to index: Int) {
        superview?.insertSubview(self, at: index)
    }
    func moveToTop() {
        guard let superv = superview else { return }
        superview?.insertSubview(self, at: superv.subviews.count)
    }
    func moveToBottom() {
        guard let superv = superview else { return }
        superv.insertSubview(self, at: 0)
    }
}

public protocol RepeatingCreate { }

extension UIView: RepeatingCreate { }
public extension RepeatingCreate where Self: UIView {
    static func repeating(_ count: Int, configure: ((Self) -> Void)? = nil) -> [Self] {
        if count <= 0 { return [] }
        // [Self](repeating: self.init(), count: count)
        var temps: [Self] = []
        for _ in 1 ... count {
            let obj = Self.init()
            temps.append(obj)
            configure?(obj)
        }
        return temps
    }
}
    
extension UIViewController: RepeatingCreate { }
public extension RepeatingCreate where Self: UIViewController {
    static func repeating(_ count: Int, configure: ((Self) -> Void)? = nil) -> [Self] {
        // [Self](repeating: self.init(), count: count)
        var temps: [Self] = []
        for _ in 1 ... count {
            let obj = Self.init()
            temps.append(obj)
            configure?(obj)
        }
        return temps
    }
}
public extension UIScrollView {
    func isAtBottom(distance: CGFloat) -> Bool {
        let y = contentOffset.y + bounds.size.height
        let contentHeight = contentSize.height
        let bottom = height + bounds.origin.y
        if y > contentHeight { return true }
        if contentHeight + 1 < bottom { return false }
        if y > contentHeight - distance { return true }
        return false
    }
}

extension UICollectionView {
    func scrollTo(indexPath: IndexPath, animated: Bool = true) {
        let layout = self.collectionViewLayout
        if let frame = layout.layoutAttributesForItem(at: indexPath)?.frame {
            self.scrollRectToVisible(frame.move(y: -self.contentInset.bottom - self.height).set(height: self.height), animated: animated)
        } else {
            self.scrollToItem(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    /// 用于键盘弹起时，scrollView 的指定的 indexPath 滚动到键盘上放
    /// - Parameters:
    ///   - indexPath: 需要滚动到键盘上方的 indexPath
    ///   - view: 这个view是坐标系转换时候用的，一般给 controller 的 view 即可
    ///   - marginBottom: 一般是键盘高度，如果键盘上方还有输入框之类的东西，需要加上键盘上方空控件的高度
    ///   - animated: 如果是放在 keyboard 动画里面，则给 false 即可，否则自行判断是否需要动画
    func scroll(to indexPath: IndexPath?, contrast view: UIView?, marginBottom: CGFloat, contentInsetBottom: CGFloat, animated: Bool = true) {
        guard let indexPath = indexPath,
            let indexCellFrame = layoutAttributesForItem(at: indexPath)?.frame else {
            return
        }
        let rect = convert(indexCellFrame, to: view)
        let delta = marginBottom - rect.y - rect.height
        
        var newPointY = contentOffset.y - delta
        if newPointY < 0 { newPointY = 0 }
        
        setContentOffset(MakePoint(contentInset.left, newPointY), animated: false)
        UIView.performWithoutAnimation { // bugfix: cell 突然消失的问题
            layoutIfNeeded()
        }
    }
    /// 和上面是一套，用来恢复 contentInset 和 scrollindicatorInsets
    /// - Parameter contentInsetBottom: value
    func scrollRecover() {
        let __boundsY = bounds.y
        if (__boundsY + height) >= contentSize.height {
            let recoverOffsetY = (contentSize.height - height) <= 0 ? 0 : (contentSize.height - height)
            setContentOffset(MakePoint(contentInset.left, recoverOffsetY), animated: false)
        } else {
            setContentOffset(MakePoint(contentInset.left, __boundsY), animated: false)
        }
    }
}

extension UITableView {
    func scrollTo(indexPath: IndexPath, animated: Bool = true) {
        if let visibleIndexPaths = indexPathsForVisibleRows,
            visibleIndexPaths.contains(indexPath),
            let cell = cellForRow(at: indexPath) {
            self.scrollRectToVisible(cell.frame.move(y: -self.contentInset.bottom).set(height: self.height), animated: animated)
        } else {
            self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
}

protocol TransitionView { }
extension UIView: TransitionView { }
extension TransitionView where Self: UIView {
    func transition(duration: TimeInterval, options: AnimationOptions = [.allowUserInteraction, .transitionCrossDissolve, .curveEaseOut], animations: ((Self) -> Void)?, completion: ((Self, Bool) -> Void)?) {
        UIView.transition(with: self, duration: duration, options: options, animations: { [weak self] in
            guard let self = self else { return }
            animations?(self)
            
        }, completion: { [weak self] (completed) in
            guard let self = self else { return }
            
            completion?(self, completed)
        })
    }
}
