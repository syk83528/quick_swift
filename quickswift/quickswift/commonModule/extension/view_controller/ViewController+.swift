//
//  ViewController+.swift
//  spsd
//
//  Created by 未来 on 2019/12/4.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import common
import ReactiveSwift
import ReactiveCocoa
import YTPageController

extension UIViewController {
    public static var current: UIViewController? {
        guard let window = SceneDelegate.shared?.window, let r = window.rootViewController else {
            return nil
        }
        
        var root:UIViewController? = r
        while root!.presentedViewController != nil {
            root = root!.presentedViewController
        }
        
        if let nav = root! as? UINavigationController {
            if nav.visibleViewController is MainViewController, let tab = nav.visibleViewController as? MainViewController {
                if let page = tab.selectedViewController as? YTPageController {
                    return page.currentViewController
                } else {
                    return tab.selectedViewController
                }
            }
            return nav.visibleViewController
        }
        return root
        
    }
    
}

extension UIViewController {

    enum BarButtonItemPositionType {
        case left
        case right
    }
    enum BarButtonItemStyleType: Hashable {
        // 单独设置 normal 和 highlighted 颜色/字体
        case normalColor
        case highlightedColor
        case normalFont
        case hilightedFont

        // 优先级最高, 设置了 color 或者 font 之后，其他的 normal/highlighted Color/Font 都失效
        // for all color/font of status
        case color
        case font
    }
    
    @discardableResult
    func addBarButton(title: String, action: Selector?, styles: [BarButtonItemStyleType: Any] = [:], position pos: BarButtonItemPositionType = .right) -> UIBarButtonItem {
        let item = UIBarButtonItem.init(title: title, style: .plain, target: self, action: action)

        let normalColor = styles[.color].or(styles[.normalColor].or(UIColor.gray))
        let normalFont = styles[.font].or(styles[.normalFont].or(UIFont.systemFont(ofSize: 12)))
        let normalAttr = [NSAttributedString.Key.font: normalFont,
                          NSAttributedString.Key.foregroundColor: normalColor]
        item.setTitleTextAttributes(normalAttr, for: .normal)

        let highlightedColor = styles[.color].or(styles[.highlightedColor].or(UIColor.black))
        let highlightedFont = styles[.font].or(styles[.hilightedFont].or(UIFont.systemFont(ofSize: 12)))
        let highlightAtttr = [NSAttributedString.Key.font: highlightedFont,
                              NSAttributedString.Key.foregroundColor: highlightedColor]
        item.setTitleTextAttributes(highlightAtttr, for: .highlighted)

        if pos == .left {
            self.navigationItem.leftBarButtonItem = item
        } else {
            self.navigationItem.rightBarButtonItem = item
        }
        return item
    }
    
    @discardableResult
    func addBarButton(image: UIImage?, action: Selector?, position pos: BarButtonItemPositionType = .right) -> UIBarButtonItem {
        let item = UIBarButtonItem.init(image: image, style: .plain, target: self, action: action)
        if pos == .left {
            self.navigationItem.leftBarButtonItem = item
        } else {
            self.navigationItem.rightBarButtonItem = item
        }
        return item
    }
    
//    func addBackButton(color: UIColor = .white) {
//        let backButton = UIButton()
//        backButton.tag = -111
//        backButton.setImage(UIImage(named: "general_back")?.tintColor(color), for: .normal)
//        backButton.r.touchUpInside.do {
//            [weak self] in
//            self?.dismiss()
//        }
//        backButton.contentHorizontalAlignment = .left
//        backButton.contentVerticalAlignment = .center
//        backButton.enlargeEdge = 10
//        backButton.add(to: view)
//        backButton.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.height + 8)
//            make.size.equalTo(30)
//        }
//    }
//
//    func addTitle(color: UIColor = .white) {
//        let label = UILabel(text: title, font: .semibold(17), color: color, alignment: .center)
//        label.add(to: view)
//        label.snp.makeConstraints { (make) in
//            make.width.lessThanOrEqualToSuperview().dividedBy(1.5)
//            make.centerX.equalToSuperview()
//            if let v = view.viewWithTag(-111) {
//                make.centerY.equalTo(v)
//            } else {
//                make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.height + 12)
//            }
//        }
//    }
    
    func move(to newViewController: UIViewController?, viewFrame: CGRect) {
        willMove(toParent: newViewController)
        newViewController?.view.addSubview(view)
        view.frame = viewFrame
        newViewController?.addChild(self)
        didMove(toParent: newViewController)
    }
}

extension UIViewController {
    func setNavigationBarBackgroundColor(_ backgroundColor: UIColor?) {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.barTintColor = .backgroundColor
    }
    /// 导航栏title文字颜色
    func setNavigationBarTitleTintColor(_ color: UIColor, alpha: CGFloat = 1) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color.alpha(alpha)]
    }
    /// 导航栏leftItem rightItem文字渲染颜色(图片自己弄渲染模式)
    func setNavigationBarTintColor(_ color: UIColor, alpha: CGFloat = 1) {
        navigationController?.navigationBar.tintColor = color.alpha(alpha)
    }
    
    /// 移除导航栏的那根线
    func removeNavigationBarLine() {
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        navBar.shadowImage = UIImage()
        
        if Device.version.float < 11 {
            
            //            NSObject.ignoreError({
            for i in navBar.subviews {
                if let clz = NSClassFromString("_UIBarBackground") {
                    if i.isKind(of: clz) {
                        for obj in i.subviews {
                            if obj.isKind(of: UIImageView.self) {
                                obj.isHidden = true
                            }
                        }
                    }
                }
            }
//            return nil
            //            })
        }
    }
    
    /// 导航栏透明, 但不会改变 safeArea
    func transparentNavigationBar() {
        // signal: bugfix on iOS 12.4.1, compatible iOS 13
        // on iOS 12, _UIBarBackground 隐藏后 push 到新界面会重新显示
        let viewDidlayoutSubviews = self.r.signal(for: #selector(viewDidLayoutSubviews))
        Signal.merge(viewDidlayoutSubviews).take(duringLifetimeOf: self).observeValues({ [weak self] (_) in
            self?.__transparent()
        })
        
        guard Device.version.float < 13, let navBar = navigationController?.navigationBar else {
            return
        }
        navBar.r.signal(for: #selector(UIView.layoutSubviews)).take(duringLifetimeOf: self).observeValues { [weak self] (_) in
            self?.__transparent()
        }
    }
    
    private func __transparent() {
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        
        NSObject.ignoreError({
            for i in navBar.subviews {
                // ios 10 and after
                var clz: AnyClass? = NSClassFromString("_UIBarBackground")
                if clz == nil {
                    // ios 10 before
                    clz = NSClassFromString("_UINavigationBarBackground")
                }
                if clz != nil {
                    if i.isKind(of: clz!) {
                        i.isHidden = true
                        i.alpha = 0
                        i.backgroundColor = .clear
                        i.removeFromSuperview()
                        for obj in i.subviews {
                            if obj.isKind(of: UIImageView.self) {
                                obj.isHidden = true
                                i.alpha = 0
                                i.backgroundColor = .clear
                            }
                        }
                    }
                }
            }
            return nil
        })
    }
    
//    func insertBottomWhiteMask(below: UIView? = nil, height: CGFloat = .tabBarHeight) {
//        let mask = GradientView.whiteVerticalReversed
//        if let below = below {
//            view.insertSubview(mask, belowSubview: below)
//        } else {
//            view.addSubview(mask)
//        }
//        self.r.signal(for: #selector(viewDidLayoutSubviews)).take(duringLifetimeOf: self).observeValues { [weak self] (_) in
//            guard let self = self else { return }
//
//            if let belowView = below {
//                mask.pin.bottom().horizontally().height(self.view.height - belowView.y)
//            } else {
//                mask.pin.bottom().horizontally().height(height)
//            }
//        }
//    }
    
//    func insertTopWhiteMask(below: UIView? = nil, height: CGFloat = .navigationBarHeight) {
//        let mask = GradientView.whiteVertical
//        if let below = below {
//            view.insertSubview(mask, belowSubview: below)
//        } else {
//            view.addSubview(mask)
//        }
//        self.r.signal(for: #selector(viewDidLayoutSubviews)).take(duringLifetimeOf: self).observeValues { (_) in
//            mask.pin.horizontally().top().height(height)
//        }
//    }
    
    /// 渐变色导航栏背景，colors.count = 2, 返回渐变色背景(GradientView)
    /// 如果需要在滑动时显示/隐藏 navigationBar 的 title，使用 navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.alpha(dynamicAlpha)]
    /// 不然有无法预料的 bug 😭
    /// - Parameter backgroundColors: 两个数量
    /// - Parameter direction: 渐变色渲染方向
    /// - Returns: GradientView's instance
//    @discardableResult
//    func setNavigationBarBackgroundColors(_ backgroundColors: [UIColor], direction: JSTGradientPosition = .vertical) -> GradientView {
//        transparentNavigationBar()
//        removeNavigationBarLine()
//
//        let graidentView = JSTGradientView(frame: MakeRect(0, -.navigationBarHeight, ScreenWidth, .navigationBarHeight))
//        graidentView.colors = backgroundColors
//        graidentView.position = direction
//        view.addSubview(graidentView)
//        return graidentView
//    }
    
    /// 设置导航栏标题颜色
    /// - Parameter color: 颜色
    func setNavTitleColor(color: UIColor) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
    }
    /// 右侧多个按钮时，最左侧按钮X位置移动，用于2个按钮距离过宽时
    func setNavSpace(leftX: CGFloat) {
        guard let navBar = navigationController?.navigationBar,
            let cls1 = NSClassFromString("_UINavigationBarContentView"),
            let cls2 = NSClassFromString("_UIButtonBarStackView"),
            let cls3 = NSClassFromString("_UIButtonBarButton") else {
            return
        }
        NSObject.ignoreError({
            for i in navBar.subviews {
                if i.isKind(of: cls1) {
                    for obj in i.subviews {
                        /// 右侧的按钮
                        if obj.isKind(of: cls2), obj.frame.origin.x > 50 {
                            for vw in obj.subviews {
                                if vw.isKind(of: cls3), vw.frame.origin.x == 0 {
                                    var react = vw.frame
                                    react.origin.x = leftX
                                    vw.frame = react
                                }
                            }
                        }
                    }
                }

            }
            return nil
        })
        
    }
}

//extension UIViewController {
//
//    func backIndicatorColor(light: Bool) {
//        guard let backImage = navigationItem.leftBarButtonItem?.image else { return }
//        if light {
//            navigationItem.leftBarButtonItem?.image = backImage.tintColor(.white)?.withRenderingMode(.alwaysOriginal)
//        } else {
//            navigationItem.leftBarButtonItem?.image = backImage.tintColor(.black)?.withRenderingMode(.alwaysOriginal)
//        }
//    }
//
//}

//extension UIViewController {
//
//    func wrapNavigation() -> RTRootNavigationController {
//        return RTRootNavigationController.init(rootViewController: self)
//    }
//}

protocol Setupable {
    func commonInit()
    func layout()
}
extension Setupable where Self: UIViewController {
    func activatingSetupable() {
        commonInit()
        
        r.signal(for: #selector(UIViewController.viewDidLayoutSubviews)).take(duringLifetimeOf: self).observeValues { [weak self] (_) in
            self?.layout()
        }
    }
}
