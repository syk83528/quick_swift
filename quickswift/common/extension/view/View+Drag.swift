//
//  View+Drag.swift
//  spsd
//
//  Created by JunFly on 2020/12/4.
//  Copyright © 2020 未来. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

fileprivate extension Keys {
    struct UIView {
        static var isDragEnable = "UIView.isDragEnable"
        static var isDragAdsorption = "UIView.isDragAdsorption"
        static var lastDraggedPosition = "UIView.lastDraggedPosition"
    }
}

protocol UIViewDragProtocol where Self: UIView {
    
    var isDragEnable: MutableProperty<Bool>? { get }
    
    /// 不要使用多次，不要使用多次，不要使用多次
    /// - Parameters:
    ///   - safeEdge: 移动的安全区域
    ///   - isAdsorption: 是否开启吸附效果
    ///   - duringLifetimeOf: 销毁
    /// - Returns: Disposable
    func configDrag(safeEdge: UIEdgeInsets, isAdsorption: Bool, duringLifetimeOf: AnyObject) -> Disposable
    
    var initialDragPosition: CGPoint { get set }
}

private var initialDragPositionKey: UInt8 = 0
extension UIView: UIViewDragProtocol {
    var initialDragPosition: CGPoint {
        get {
            associatedObject(&initialDragPositionKey) {
                CGPoint(x: Screen.width - 8 - Screen.width / 4, y: 60)
            }
        }
        set {
            setAssociatedObject(&initialDragPositionKey, newValue)
        }
    }
    
    var isDragEnable: MutableProperty<Bool>? {
        get {
            if let temp = property(for: &Keys.UIView.isDragEnable) as? MutableProperty<Bool> {
                return temp
            }
            let a = MutableProperty<Bool>(false)
            setProperty(for: &Keys.UIView.isDragEnable, a)
            return a
        }
        set {
            setProperty(for: &Keys.UIView.isDragEnable, newValue)
        }
    }
    
    
    var lastDraggedPosition: CGPoint {
        get {
            if let tempPoint = property(for: &Keys.UIView.lastDraggedPosition) as? CGPoint {
                return tempPoint
            }
            let point = initialDragPosition
            setProperty(for: &Keys.UIView.lastDraggedPosition, point)
            return point
        }
        set {
            setProperty(for: &Keys.UIView.lastDraggedPosition, newValue)
        }
    }
    
    private func panMove(_ pan: UIPanGestureRecognizer) {
        guard let panView = pan.view, panView == self else { return }
        
        let point = pan.translation(in: self.superview)
        panView.center = CGPoint(x: panView.center.x + point.x, y: panView.center.y + point.y)
        pan.setTranslation(.zero, in: self.superview)
    }
        
    private func panEnded(_ pan: UIPanGestureRecognizer, safeEdge: UIEdgeInsets = .init(top: 60, left: 8, bottom: 60, right: 8), isAdsorption: Bool = true) {
        
        guard let panView = pan.view, let superview = self.superview else { return }
        
        guard isAdsorption else { return }
        
        var newOrigin: CGPoint = .zero
        let safeEdge = safeEdge == .zero ? .init(top: 60, left: 8, bottom: 60, right: 8) : safeEdge
        
        let marginLeft = panView.frame.origin.x
        let marginRight = superview.frame.size.width - panView.frame.origin.x - panView.frame.size.width
        let marginTop = panView.frame.origin.y
        let marginSafeTop = superview.frame.height - panView.frame.height - safeEdge.bottom // 不超出safe的最大y
        
        let xfunc = {
            marginLeft < marginRight
                ? marginLeft < safeEdge.left ? safeEdge.left : marginLeft
                : marginRight < safeEdge.right ? superview.frame.width - panView.frame.width - safeEdge.right : marginLeft
        }
        if marginTop >= marginSafeTop {
            newOrigin.y = marginSafeTop
            newOrigin.x = xfunc()
        } else if marginTop <= safeEdge.top {
            newOrigin.y = safeEdge.top
            newOrigin.x = xfunc()
        } else {
            newOrigin.y = marginTop
            newOrigin.x = marginLeft < marginRight ? safeEdge.left : superview.frame.width - panView.frame.width - safeEdge.right
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            panView.frame.origin = newOrigin
        })
        if panView == self {
            lastDraggedPosition = newOrigin
        }
    }
    
    /// 不要使用多次，不要使用多次，不要使用多次
    /// - Parameters:
    ///   - safeEdge: 移动的安全区域
    ///   - isAdsorption: 是否开启吸附效果
    ///   - enabled: 是否启动拖动
    ///   - duringLifetimeOf: 销毁
    /// - Returns: Disposable
    @discardableResult
    func configDrag(safeEdge: UIEdgeInsets = .init(top: 60, left: 8, bottom: 60, right: 8), isAdsorption: Bool = true, duringLifetimeOf: AnyObject) -> Disposable {
        return SignalProducer<Never, Never> { (observer, signalLifetime) in
            let baseView = self
            
            let panGesture = UIPanGestureRecognizer()
            baseView.addGestureRecognizer(panGesture)
            panGesture.maximumNumberOfTouches = 1
            
            if let dragEnabled = self.isDragEnable {
                signalLifetime += panGesture.reactive.isEnabled <~ dragEnabled
            }
            signalLifetime += panGesture.reactive.stateChanged.take(duringLifetimeOf: duringLifetimeOf).observeValues { (gesture) in
                switch gesture.state {
                case .changed:
                    self.panMove(gesture)
                case .ended, .cancelled, .failed:
                    self.panEnded(gesture, safeEdge: safeEdge, isAdsorption: isAdsorption)
                default:
                    break
                }
            }
            signalLifetime.observeEnded {
                observer.sendCompleted()
                baseView.removeGestureRecognizer(panGesture)
            }
        } .take(duringLifetimeOf: duringLifetimeOf).start()
    }
}
