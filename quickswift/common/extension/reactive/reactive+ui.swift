////
////  reactive+ui.swift
////  common
////
////  Created by suyikun on 2022/7/27.
////
//
import Foundation
import ReactiveCocoa
import ReactiveSwift


extension Reactive where Base: UIControl {
    
    var touchUpInside: Signal<Base, Never> {
        if !base.isUserInteractionEnabled {
            base.isUserInteractionEnabled = true
        }
        return controlEvents(.touchUpInside)
    }
    
}
//
public extension Reactive where Base: UIView {

    enum DragDirection {
        case left, right
    }

    /// UITapGestureRecognizer
    var tap: Signal<UITapGestureRecognizer, Never> {
        tap(touches: 1, taps: 1)
    }
    var pan: Signal<UIPanGestureRecognizer, Never> {
        base.isUserInteractionEnabled = true
        let t = UIPanGestureRecognizer()
        base.addGestureRecognizer(t)
        t.maximumNumberOfTouches = 1
        return t.reactive.stateChanged.take(during: lifetime)
    }

    /// 拖动View, 生命周期结束时，所有的 UIGesture 都会被移除
    /// - Parameters:
    ///   - safeEdge: 安全边距
    ///   - isAdsorption: 停止时是否吸附，默认为 true
    func drag(safeEdge: UIEdgeInsets, isAdsorption: Bool = true) -> Signal<DragDirection, Never> {

        return .init { (observer, signalLifetime) in

            func panMove(_ pan: UIPanGestureRecognizer) {
                guard let panView = pan.view else { return }

                let point = pan.translation(in: base.superview)
                panView.center = CGPoint(x: panView.center.x + point.x, y: panView.center.y + point.y)
                pan.setTranslation(.zero, in: base.superview)
            }

            func panEnded(_ pan: UIPanGestureRecognizer) {
                guard let panView = pan.view else { return }

                var newOrigin: CGPoint = .zero
                if panView.center.x > (.screenWidth / 2) {
                    newOrigin.x = .screenWidth - panView.width - safeEdge.right
                    observer.send(value: .right)
                } else {
                    newOrigin.x = safeEdge.left
                    observer.send(value: .left)
                }

                guard isAdsorption else { return }

                if panView.bottom >= (.screenHeight - panView.height - safeEdge.bottom) {
                    newOrigin.y = (.screenHeight - panView.height - safeEdge.bottom)
                } else if panView.y <= safeEdge.top {
                    newOrigin.y = safeEdge.top
                } else {
                    newOrigin.y = panView.y
                }
                UIView.animate(withDuration: 0.3, animations: {
                    panView.origin = newOrigin
                })
            }

            let panGesture = UIPanGestureRecognizer()
            base.addGestureRecognizer(panGesture)
            panGesture.maximumNumberOfTouches = 1

            panGesture.reactive.stateChanged.take(during: lifetime).observeValues { (gesture) in
                if gesture.state == .changed {
                    panMove(gesture)
                } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                    panEnded(gesture)
                }
            }

            let disposable = lifetime.ended.observeCompleted(observer.sendCompleted)
            signalLifetime.observeEnded {
                disposable?.dispose()
                self.base.removeGestureRecognizer(panGesture)
            }
        }
    }

    /// UILongPressGestureRecognizer
    func longPress(minimum pressDuration: TimeInterval, touches: Int = 1, taps: Int = 0, movement: CGFloat = 15.0) -> Signal<UILongPressGestureRecognizer, Never> {
        base.isUserInteractionEnabled = true
        let l = UILongPressGestureRecognizer.init()
        l.minimumPressDuration = pressDuration
        l.numberOfTouchesRequired = touches
        l.numberOfTapsRequired = taps
        l.allowableMovement = movement
        base.addGestureRecognizer(l)

        if let tapGesture = base.gestureRecognizers?.filter({ $0 is UITapGestureRecognizer }).first {
            tapGesture.require(toFail: l)
        }
        return l.reactive.stateChanged.take(during: lifetime)
    }

    func tap(touches: Int = 1, taps: Int = 1, cancelsTouchesInView: Bool = true) -> Signal<UITapGestureRecognizer, Never> {
        base.isUserInteractionEnabled = true
        let t = UITapGestureRecognizer.init()
        base.addGestureRecognizer(t)
        t.numberOfTouchesRequired = touches
        t.numberOfTapsRequired = taps
        t.cancelsTouchesInView = cancelsTouchesInView
        return t.reactive.stateChanged.take(during: lifetime)
    }

    func swipe(direction: UISwipeGestureRecognizer.Direction = .right) -> Signal<UISwipeGestureRecognizer, Never> {
        base.isUserInteractionEnabled = true
        let t = UISwipeGestureRecognizer()
        base.addGestureRecognizer(t)
        t.direction = direction
        return t.reactive.stateChanged.take(during: lifetime)
    }
}
//
//extension Signal where Value: UIButton, Error == Never {
//
//    @discardableResult
//    func bind(push viewController: UIViewController, params: Dict? = nil) -> Signal<Value, Error> {
//        weak var vc = viewController
//        observeValues { (_) in
//            vc?.push(params)
//        }
//        return self
//    }
//
//    @discardableResult
//    func bind<T: UIViewController>(push to: T.Type, params: Dict? = nil) -> Signal<Value, Error> {
//        observeValues { (_) in
//            to.push(params)
//        }
//        return self
//    }
//
//    @discardableResult
//    func dismiss(_ viewController: UIViewController, animate: Bool = true, completion: (() -> Void)? = nil) -> Signal<Value, Error> {
//        weak var vc = viewController
//        observeValues { (_) in
//            vc?.dismiss(completion: completion, animated: animate)
//        }
//        return self
//    }
//}
//
//extension Signal where Value: UITapGestureRecognizer, Error == Never {
//
//    @discardableResult
//    func endEditing(_ view: UIView) -> Disposable? {
//        weak var __view = view
//        return observeValues { (_) in
//            __view?.endEditing(true)
//        }
//    }
//
//    @discardableResult
//    func bind<T: UIViewController>(push controller: T.Type, params: Dict? = nil) -> Disposable? {
//        return observeValues { (_) in
//            controller.push(params, animated: true)
//        }
//    }
//}
//
//extension Reactive where Base: UIImageView {
//
//    var load: BindingTarget<URL?> {
//        makeBindingTarget({ $0.load($1) })
//    }
//
//}
//
//extension Signal where Value: UIButton, Error == Never {
//
//    @discardableResult
//    func bind(push viewController: UIViewController, params: Dict? = nil) -> Signal<Value, Error> {
//        weak var vc = viewController
//        observeValues { (_) in
//            vc?.push(params)
//        }
//        return self
//    }
//
//    @discardableResult
//    func bind<T: UIViewController>(push to: T.Type, params: Dict? = nil) -> Signal<Value, Error> {
//        observeValues { (_) in
//            to.push(params)
//        }
//        return self
//    }
//
//    @discardableResult
//    func dismiss(_ viewController: UIViewController, animate: Bool = true, completion: (() -> Void)? = nil) -> Signal<Value, Error> {
//        weak var vc = viewController
//        observeValues { (_) in
//            vc?.dismiss(completion: completion, animated: animate)
//        }
//        return self
//    }
//}
//
//extension SignalProducer {
//
//    @discardableResult
//    func dismiss(_ viewController: UIViewController?) -> SignalProducer<Value, Error> {
//        guard let c = viewController else { return producer }
//        return producer.observe(on: QueueScheduler.main).on(success: { [weak c] (_) in
//            c?.dismiss()
//        })
//    }
//    @discardableResult
//    func push<T: UIViewController>(_ viewController: T.Type) -> SignalProducer<Value, Error> {
//        producer.observe(on: QueueScheduler.main).on(success: { (_) in
//            viewController.push()
//        })
//    }
//    @discardableResult
//    func push(_ viewController: UIViewController?) -> SignalProducer<Value, Error> {
//        guard let c = viewController else { return producer }
//        return producer.observe(on: QueueScheduler.main).on(success: { [weak c] (_) in
//            c?.push()
//        })
//    }
//    @discardableResult
//    func disable(_ views: UIView...) -> SignalProducer<Value, Error> {
//        let weakViews = views.map { (v) -> UIView? in
//            weak var wv = v
//            return wv
//        }
//        return producer.observe(on: QueueScheduler.main).on(starting: {
//            weakViews.forEach({
//                if let control = $0 as? UIControl {
//                    control.isEnabled = false
//                } else {
//                    $0?.isUserInteractionEnabled = false
//                }
//            })
//        }, terminated: {
//            weakViews.forEach({
//                if let control = $0 as? UIControl {
//                    control.isEnabled = true
//                } else {
//                    $0?.isUserInteractionEnabled = true
//                }
//            })
//        })
//    }
//    @discardableResult
//    func endEditing(_ view: UIView) -> SignalProducer<Value, Error> {
//        producer.observe(on: QueueScheduler.main).on(starting: { [weak view] in
//            view?.endEditing(true)
//        })
//    }
//
//    @discardableResult
//    func notif(_ notif: Notif, userInfo: AnyDict? = nil, object: Any? = nil) -> SignalProducer<Value, Error> {
//        producer.on(success: { (value) in
//            var postUserInfo = userInfo
//            if userInfo == nil {
//                postUserInfo = ["__source": value]
//            }
//            var postObject = object
//            if object == nil {
//                postObject = value
//            }
//            notif.post(userInfo: postUserInfo, object: postObject)
//        })
//    }
//
//    @discardableResult
//    func spinner(_ text: String) -> Self {
//        return spinner(text, blockInteraction: .block, gracetime: 0.5)
//    }
//
//    @discardableResult
//    func spinner(_ text: String? = nil, successToast: String? = nil, blockInteraction: Baker.Interaction = .block, gracetime: TimeInterval = 0.5) -> Self {
//        let toast = Toast(text, style: .spinner, interaction: blockInteraction, delay: gracetime)
//        return producer.on(starting: {
//            Common.Queue.main {
//                toast.show()
//            }
//        }, started: nil, event: nil, failed: nil, completed: nil, interrupted: {
//            Common.Queue.main {
//                toast.dismiss()
//            }
//        }, terminated: {
//            Common.Queue.main {
//                toast.dismiss()
//            }
//        }, disposed: {
//            Common.Queue.main {
//                toast.dismiss()
//            }
//        }, value: { (_) in
//            if let sToast = successToast {
//                Common.Queue.main {
//                    Toast(sToast).show()
//                }
//            }
//        })
//    }
//
//    @discardableResult
//    func successToast(_ text: String?) -> SignalProducer<Value, Error> {
//        producer.on(value: { _ in
//            Common.Queue.main {
//                Toast(text, haptic: .light).show()
//            }
//        })
//    }
//
//    /// confirm 后不需要再到后面使用 .start(), 点击 alert 的确认即会发送网络请求
//    /// alert 在 dismiss 时会将 block 重置为 nil，所以无需担心循环引用
//    /// buttonTitles: "取消,确认", 逗号分割即可
//    /// confirmBlock: return true 时执行 start(), false 不执行
//    @discardableResult
//    func alertConfirm(title: String, content: String?, buttonTitles: String?, confirm: (() -> Bool)? = nil) -> SignalProducer<Value, Error> {
//        let alert = Alert().then({
//            $0.title = title
//            $0.buttonTitles = buttonTitles
//            $0.content = content
//        })
//        alert.show(confirmAction: { (_) -> Bool in
//            if let confirm = confirm {
//                if confirm() == true {
//                    self.producer.start()
//                }
//            } else {
//                self.producer.start()
//            }
//            return true
//        }, cancelAction: nil, mode: .all)
//        return producer
//    }
//
//    @discardableResult
//    func markDirty(_ view: UIView) -> SignalProducer<Value, Error> {
//        producer.success { [weak view] _ in
//            view?.flex.markDirty()
//        }
//    }
//
//    @discardableResult
//    func needsLayout(_ view: UIView) -> SignalProducer<Value, Error> {
//        producer.success { [weak view] _ in
//            view?.setNeedsLayout()
//        }
//
//    }
//}
