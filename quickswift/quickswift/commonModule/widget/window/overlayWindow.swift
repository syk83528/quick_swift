//
//  OverlayWindow.swift
//  spsd
//
//  Created by 未来 on 2019/12/6.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit
import common

extension Notif {
    static let overlayShouldDismiss = Notif("overlayShouldDismiss")
}

class OverlayWindow: UIWindow, WindowValidation {
    
    static let shared = OverlayWindow(frame: UIWindow.customBounds)
    
    lazy var dimmingView = UIView().then {
        $0.backgroundColor = UIColor.black.alpha(0.2)
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIWindow.customBounds)
        windowLevel = .overlay
        isHidden = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        isHidden = false
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        guard subviews.count == 1 else {
            isHidden = false
            return
        }
        if RunLoop.main.currentMode == .tracking {
            self.perform(#selector(delayHidden), with: nil, afterDelay: 0, inModes: [.default])
        } else {
            isHidden = true
        }
    }
    
    @objc private func delayHidden() {
        isHidden = true
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews.reversed() {
            guard !view.isHidden, view.alpha > 0, view.isUserInteractionEnabled,
                view.frame.contains(point) else {
                    continue
            }
            if view is PointInsideOnDemandView {
                let innerPoint = convert(point, to: view)
                return view.point(inside: innerPoint, with: event)
            }
            return true
        }
        return false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in subviews.reversed() {
            guard !view.isHidden, view.alpha > 0, view.isUserInteractionEnabled,
                view.frame.contains(point) else {
                    continue
            }
            let innerPoint = convert(point, to: view)
            if view is ClickThroughView {
                if let target = view.hitTest(innerPoint, with: event) {
                    return target
                }
            } else {
                return view.hitTest(innerPoint, with: event)
            }
        }
        return nil
    }
    
    var isValid: Bool {
        false
    }
}

extension OverlayWindow {
    
    func show(controller: UIViewController) {
        let size = controller.preferredContentSize
        guard let view = controller.view, size > 0 else { return }
        
        controller.willMove(toParent: nil)
        show(view: view, size: size)
        controller.didMove(toParent: nil)
    }
    
    /// 手动设置size
    func show(view: UIView, size: CGSize) {
        view.isHidden = true
        view.size = size
        view.y = .screenHeight + size.height
        
        view.isHidden = false
        view.add(to: self)
        
        // 添加的时候添加手势
        dimmingView.r.tap.observeValues { [weak self] (tap) in
            guard tap.view?.isHidden == false else { return }
            self?.dismiss()
        }?.disposeBag(dimmingView, tag: "tap")
        if dimmingView.isHidden {
            self.insertSubview(dimmingView, at: 0)
            dimmingView.frame = MakeRect(0, 0, .screenWidth, .screenHeight)
            dimmingView.alpha = 0
            dimmingView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dimmingView.alpha = 1
            view.y = .screenHeight - (size.height + .safeAreaBottom)
        }) { (_) in
            self.dimmingView.alpha = 1
            view.y = .screenHeight - (size.height + .safeAreaBottom)
            
        }
    }
    
    // 取view的size, view自己dismiss
    func show(view: UIView) {
        view.isHidden = false
        view.add(to: self)
    }
    
    /// 一般交给 dimmingView 来操作
    func dismiss() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            for view in self.subviews.filter({ $0 != self.dimmingView }) {
                view.transform = .init(translationX: 0, y: view.height)
            }
            self.dimmingView.alpha = 0
        }) { (_) in
            self.dimmingView.isHidden = true
            self.subviews.forEach({
                $0.removeFromSuperview()
            })
        }
    }
}
// MARK: - --------------------------------------指定动画方式

extension OverlayWindow {
    func showSlide(_ controller: UIViewController) {
        let size = controller.preferredContentSize
        guard let view = controller.view, size > 0 else { return }
        controller.willMove(toParent: nil)
        view.add(to: self)
        controller.didMove(toParent: nil)
        
        view.isHidden = false
        view.size = size
        view.right = 0
        view.top = 0
        
        // 添加的时候添加手势
        dimmingView.r.tap.observeValues { [weak self] (tap) in
            guard let self = self else { return }
            guard tap.view?.isHidden == false else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                for view in self.subviews.filter({ $0 != self.dimmingView }) {
                    view.transform = .init(translationX: -view.size.width, y: 0)
                }
                self.dimmingView.alpha = 0
            }) { (_) in
                self.dimmingView.isHidden = true
                self.subviews.forEach({
                    $0.removeFromSuperview()
                })
            }
        }?.disposeBag(dimmingView, tag: "tap")
        if dimmingView.isHidden {
            self.insertSubview(dimmingView, at: 0)
            dimmingView.frame = MakeRect(0, 0, .screenWidth, .screenHeight)
            dimmingView.alpha = 0
            dimmingView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dimmingView.alpha = 1
            view.left = 0
        }) { (_) in
            self.dimmingView.alpha = 1
            view.left = 0
        }
    }
}
