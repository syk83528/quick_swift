//
//  Baker.swift
//  spsd
//
//  Created by Wildog on 1/2/20.
//  Copyright © 2020 Wildog. All rights reserved.
//

import UIKit
import ReactiveCocoa
import common

protocol Bakable: AnyObject, CustomStringConvertible {
    var haptic: Baker.Haptic { get }
    var interaction: Baker.Interaction { get }
    var background: Baker.Background { get }
    var position: Baker.Position { get }
    var style: Baker.Style { get }
    var timeout: TimeInterval? { get }
    var delay: TimeInterval? { get }

    var bakingView: BakingView.Type { get }

    var text: String? { get }
    var attributedText: NSAttributedString? { get }
    var progress: CGFloat? { get }
    
    var behavior: Baker.Behavior { get set }
    var operation: Operation? { get set }
    var appearing: (() -> Void)? { get set }
    var completion: (() -> Void)? { get set }
}

extension Bakable {
    var description: String {
        "Bakable: " +
        (self.text ?? self.attributedText?.string ?? "") +
        ", style: \(style)" +
        ", position: \(position)"
    }
    
    var defaultTimeout: TimeInterval {
        if style.isForever {
            return 3600
        }
        var duration: TimeInterval = 0
        if let text = text {
            duration = min(6.0, Double(text.count) * 0.06 + 0.5)
        } else if let text = attributedText {
            duration = min(6.5, Double(text.length) * 0.06 + 0.5)
        }
        duration = max(duration, 1.5)
        if position == .top {
            return duration * 2
        }
        return duration
    }
    
    @discardableResult
    func show() -> Self {
        Baker.shared.show(self)
        return self
    }
    
    @discardableResult
    func onCompleted(_ closure: (() -> Void)?) -> Self {
        self.completion = closure
        return self
    }
    
    @discardableResult
    func onAppearing(_ closure: (() -> Void)?) -> Self {
        self.appearing = closure
        return self
    }
    
    func dismiss() {
        operation?.cancel()
    }
}

protocol BakingView: UIView {
    init(with: Bakable) // create
    func bake() // configure
    func animateShow() // animate in
    func animateDismiss() // animate out
}

class Baker: ClickThroughView {
    static let shared = Baker(frame: Screen.bounds)
    
    let queues: [Baker.Position: OperationQueue] = [
        .center: OperationQueue().then({ $0.maxConcurrentOperationCount = 1 }),
        .top: OperationQueue().then({ $0.maxConcurrentOperationCount = 2 })
    ]
    
    var bgContainer: UIView = UIView().then {
        $0.isUserInteractionEnabled = false
    }
    
    lazy var dimBgView: UIView = UIView(frame: self.bgContainer.bounds).then {
        $0.backgroundColor = UIColor.black.alpha(0.4)
        $0.alpha = 0
        $0.add(to: self.bgContainer)
        $0.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var blurBgView: UIVisualEffectView = UIVisualEffectView(frame: self.bgContainer.bounds).then {
        $0.add(to: self.bgContainer)
        $0.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
        bgContainer.frame = bounds
        bgContainer.add(to: self)
        bgContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // TODO:
//        Notif.User.logout.listen(duringOf: self).do {
//            [unowned self] in
//            for (_, queue) in self.queues {
//                queue.cancelAllOperations()
//            }
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ bakable: Bakable, on presenter: UIView = OverlayWindow.shared) {
        guard let queue = queues[bakable.position] else { return }
        
        let operation = CancellableBlockOperation(block: {
            [weak self] (sem, op) in
            guard let self = self else { return }
            if let delay = bakable.delay {
                _ = DispatchSemaphore(value: 0).wait(timeout: DispatchTime.now() + delay)
            }
            Common.Queue.main {
                if op.isCancelled || op.__cancelled {
                    sem?.signal()
                    return
                }
                
                if self.superview != presenter {
                    self.frame = presenter.bounds
                    presenter.addSubview(self)
                } else {
                    self.superview?.bringSubviewToFront(self)
                }
                
                if bakable.position == .center {
                    let bakingView = bakable.bakingView.init(with: bakable)
                    op.context = bakingView
                    self.addSubview(bakingView)
                    bakingView.snp.makeConstraints { (make) in
                        make.center.equalTo(self)
                    }
                    bakingView.bake()
                    bakingView.animateShow()
                    self.bgContainer.isUserInteractionEnabled = bakable.interaction == .block
                } else if bakable.position == .top {
                    let bakingView = bakable.bakingView.init(with: bakable)
                    op.context = bakingView
                    self.addSubview(bakingView)
                    bakingView.bake()
                    bakingView.animateShow()
                }

                switch bakable.background {
                case .dim:
                    let dimBgView = self.dimBgView
                    UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                        dimBgView.alpha = 1
                    })
                case .blur:
                    let blurBgView = self.blurBgView
                    UIViewPropertyAnimator(duration: 0.25, curve: .linear) {
                        if #available(iOS 13.0, *) {
                            blurBgView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
                        } else {
                            blurBgView.effect = UIBlurEffect(style: .dark)
                        }
                    }.startAnimation()
                case .none:
                    break
                }
                
                switch bakable.haptic {
                case .normal:
                    Impacter.normal.impactOccurred()
                case .light:
                    Impacter.light.impactOccurred()
                case .heavy:
                    Impacter.heavy.impactOccurred()
                case .none:
                    break
                }
            }
        }, completionBlock: {
            [weak self] (_, op) in
            let view = op.context as? BakingView
            Common.Queue.main {
                if bakable.background == .dim, let dimBgView = self?.dimBgView {
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                        dimBgView.alpha = 0
                    })
                } else if bakable.background == .blur, let blurBgView = self?.blurBgView {
                    UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
                        blurBgView.effect = nil
                    }.startAnimation()
                }

                view?.animateDismiss()
            }
        }, timeout: (bakable.timeout ?? bakable.defaultTimeout) + (bakable.delay ?? 0))
        
        operation.createdBy = bakable
        bakable.operation = operation
        
        switch bakable.behavior {
        case let .queue(priority):
            operation.queuePriority = priority
            queue.addOperation(operation)
        case .replaceAll:
            let deferredBakables = queue.deferredBakables(filterRunning: false)
            queue.cancelAllOperations()
            operation.queuePriority = .veryHigh
            operation.immediatelyStarted = true
            queue.addOperation(operation)
            for bk in deferredBakables {
                bk.behavior = .queue(.high)
                bk.show()
            }
        case .replaceCurrent:
            let deferredBakables = queue.deferredBakables(filterRunning: true)
            queue.cancelRunningOperations()
//            queue.cancelAllOperations()
            operation.queuePriority = .veryHigh
            operation.immediatelyStarted = true
            queue.addOperation(operation)
            for bk in deferredBakables {
                bk.behavior = .queue(.high)
                bk.show()
            }
        }
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        isHidden = false
        
        guard let baguetteView = subview as? BaguetteView else { return }
        if let lastView = subviews.last(where: { ($0 is BaguetteView) && ($0 != baguetteView) }) as? BaguetteView {
            baguetteView.snp.makeConstraints { (m) in
                m.left.right.equalToSuperview().inset(14)
                m.top.equalTo(lastView.snp.bottom).offset(12)
            }
        } else {
            baguetteView.snp.makeConstraints { (m) in
                m.left.right.equalToSuperview().inset(14)
                m.top.equalToSuperview().inset(Screen.navigationHeight - 34)
            }
        }
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        isHidden = subviews.count <= 2
        
        let baguetteViews = subviews.filter { ($0 is BaguetteView) && ($0 != subview) }
        guard baguetteViews.count > 0 else { return }
        var lastView: UIView?
        for baguetteView in baguetteViews {
            if let lastView = lastView {
                baguetteView.snp.remakeConstraints { (m) in
                    m.left.right.equalToSuperview().inset(14)
                    m.top.equalTo(lastView.snp.bottom).offset(12)
                }
            } else {
                baguetteView.snp.remakeConstraints { (m) in
                    m.left.right.equalToSuperview().inset(14)
                    m.top.equalToSuperview().inset(Screen.navigationHeight - 34)
                }
            }
            lastView = baguetteView
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
}

fileprivate extension OperationQueue {
    func deferredBakables(filterRunning: Bool) -> [Bakable] {
        var deferredBakable = [Bakable]()
        for op in operations {
            guard let op = op as? CancellableBlockOperation,
                  let bk = op.createdBy as? Bakable,
                  bk.style.isForever, !op.isFinished, !op.isCancelled,
                  filterRunning ? (op.isExecuting || op.immediatelyStarted) : true
                  else {
                    continue
            }
            deferredBakable.append(bk)
        }
        return deferredBakable
    }
}

extension OperationQueue {
    func cancelRunningOperations() {
        for operation in operations {
            if operation.isExecuting {
                operation.cancel()
            } else if let op = operation as? CancellableBlockOperation,
                op.immediatelyStarted {
                operation.cancel()
            }
        }
    }
}

extension Baker {
    enum Haptic: Int {
        case none, light, normal, heavy
    }
    enum Interaction: Int {
        case none, block
    }
    enum Background: Int {
        case none, dim, blur
    }
    enum Position: Int {
        case center, top
    }
    enum Style: Equatable {
        case success, alert, fatal
        case image(UIImage)
        case spinner // 使用spinner时必须持有toast显示调用dismiss，不然会被defer

        private var rawValue: Int {
            switch self {
            case .success, .alert, .fatal, .image:
                return 1
            case .spinner:
                return 2
            }
        }
        
        var isForever: Bool {
            switch self {
            case .spinner:
                return true
            default:
                return false
            }
        }
        
        static func == (lhs: Style, rhs: Style) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        func strictEqual(to rhs: Style) -> Bool {
            switch (self, rhs) {
            case (.success, .success),
                 (.alert, .alert),
                 (.fatal, .fatal),
                 (.spinner, .spinner),
                 (.image, .image):
                return true
            default:
                return false
            }
        }
    }
    enum Behavior {
        case replaceAll // 全部消失，清空队列（当前显示的和队列中的所有的spinner会被保留并延后）
        case replaceCurrent // 只消失当前显示（当前显示的spinnner会被保留并延后），不清空队列
        case queue(_ priority: Operation.QueuePriority = .normal) // 加入队列
    }
}
