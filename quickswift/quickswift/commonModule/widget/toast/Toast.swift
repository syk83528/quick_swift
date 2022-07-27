//
//  Toast.swift
//  spsd
//
//  Created by Wildog on 1/2/20.
//  Copyright © 2020 Wildog. All rights reserved.
//

import UIKit
import common

class Toast: Bakable {
    let haptic: Baker.Haptic
    let interaction: Baker.Interaction
    let background: Baker.Background
    let position: Baker.Position = .center
    let delay: TimeInterval?
    private(set) var timeout: TimeInterval? // 默认会根据内容长度算，spinner默认为永久

    let bakingView: BakingView.Type = ToastView.self
    
    var behavior: Baker.Behavior
    weak var operation: Operation?
    var completion: (() -> Void)?
    var appearing: (() -> Void)?
    
    var style: Baker.Style {
        didSet {
            if let styleChangeBlock = styleChangeBlock {
                styleChangeBlock(style)
            } else {
                guard oldValue != style,
                    oldValue.isForever, !style.isForever else { return }
                if let operation = operation as? CancellableBlockOperation {
                    if operation.isExecuting {
                        Common.Delay.execution(delay: defaultTimeout + 0.5) {
                            [weak self] in
                            if let operation = self?.operation as? CancellableBlockOperation {
                                operation.finish()
                            }
                        }
                    } else {
                        operation.timeout = defaultTimeout
                    }
                } else {
                    timeout = defaultTimeout
                }
            }
        }
    }
    fileprivate var styleChangeBlock: ((Baker.Style) -> Void)?

    var text: String? {
        didSet {
            self.textChangeBlock?(self.text)
        }
    }
    fileprivate var textChangeBlock: ((String?) -> Void)?

    var attributedText: NSAttributedString? {
        didSet {
            self.attributedTextChangeBlock?(self.attributedText)
        }
    }
    fileprivate var attributedTextChangeBlock: ((NSAttributedString?) -> Void)?
    
    var progress: CGFloat? {
        didSet {
            self.progressChangeBlock?(self.progress)
        }
    }
    fileprivate var progressChangeBlock: ((CGFloat?) -> Void)?
    
    init(_ text: String? = nil, attributedText: NSAttributedString? = nil, style: Baker.Style = .success,
         background: Baker.Background = .none, behavior: Baker.Behavior = .replaceAll,
         interaction: Baker.Interaction = .none, haptic: Baker.Haptic = .none, timeout: TimeInterval? = nil, delay: TimeInterval? = nil) {
        self.text = text
        self.attributedText = attributedText
        if text == nil, attributedText == nil {
            self.text = ""
        }
        self.style = style
        self.background = background
        self.behavior = behavior
        self.interaction = interaction
        self.haptic = haptic
        self.timeout = timeout
        self.delay = delay
    }
    
    static func dismiss(currentOnly: Bool = true) {
        if currentOnly {
            Baker.shared.queues[.center]?.cancelRunningOperations()
        } else {
            Baker.shared.queues[.center]?.cancelAllOperations()
        }
    }
}

class ToastView: UIView, BakingView {
    var imageView: UIImageView?
    var activityView: ActivityIndicator?
    var label: UILabel?
    var currentStyle: Baker.Style
    let toast: Bakable

    required init(with: Bakable) {
        toast = with
        currentStyle = with.style
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = UIColor.black.alpha(0.65)
        layer.cornerRadius = 8.0
        clipsToBounds = true
        alpha = 0

        self.snp.makeConstraints { (make) in
            make.width.greaterThanOrEqualTo(130)
            make.width.lessThanOrEqualTo(Screen.width * 0.8)
        }
        makeViewIfNeeded()
        
        guard let toast = with as? Toast else { return }
        toast.styleChangeBlock = {
            [weak self] (_) in
            UIView.animate(withDuration: 0.25) {
                self?.bake()
            }
        }
        toast.textChangeBlock = {
            [weak self] (text) in
            guard let self = self else { return }
            self.label?.text = text
            if text == nil {
                self.label?.attributedText = self.toast.attributedText
            }
            UIView.animate(withDuration: 0.25) {
                self.superview?.layoutIfNeeded()
            }
        }
        toast.attributedTextChangeBlock = {
            [weak self] (text) in
            guard let self = self else { return }
            self.label?.attributedText = text
            if text == nil {
                self.label?.text = self.toast.text ?? ""
            }
            UIView.animate(withDuration: 0.25) {
                self.superview?.layoutIfNeeded()
            }
        }
        toast.progressChangeBlock = {
            [weak self] (progress) in
            Common.Queue.main {
                self?.activityView?.progress = Float(progress ?? 0)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeViewIfNeeded() {
        var firstView = viewWithTag(-1)
        var firstViewSize = firstView?.size
        var topInset = 16.0
        var distance = 12.0

        switch toast.style {
        case .spinner, .success, .alert, .fatal:
            switch toast.style {
            case .success, .alert, .fatal:
                topInset = 6
            default:
                distance = 16
            }
            if activityView == nil || firstView != activityView {
                firstView?.removeFromSuperview()
                firstViewSize = MakeSize(60, 60)
                activityView = ActivityIndicator(frame: MakeRect((self.width - firstViewSize!.width) / 2, (self.height - firstViewSize!.height) / 2, firstViewSize!.width, firstViewSize!.height))
                firstView = activityView
            }
        case let .image(image):
            topInset = 14
            if imageView == nil || firstView != imageView {
                firstView?.removeFromSuperview()
                imageView = UIImageView()
                firstView = imageView
                firstViewSize = image.size
            }
        }
        
        if let firstView = firstView, let firstViewSize = firstViewSize {
            firstView.tag = -1
            if firstView.superview == nil {
                addSubview(firstView)
            }
            firstView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().inset(topInset)
                make.size.equalTo(firstViewSize)
                make.centerX.equalToSuperview()
            }
        }

        if toast.text != nil || toast.attributedText != nil {
            if label == nil {
                label = buildLabel(font: .regular(14), color: .white, alignment: .center, numberOfLines: 0)
                addSubview(label!)
            }
            label?.snp.remakeConstraints({ (make) in
                if let firstView = firstView {
                    make.top.equalTo(firstView.snp_bottomMargin).offset(distance)
                    make.width.greaterThanOrEqualTo(firstView).offset(16)
                } else {
                    make.top.equalToSuperview().inset(topInset)
                }
                make.centerX.equalToSuperview()
                make.left.right.greaterThanOrEqualToSuperview().inset(16)
                make.bottom.equalToSuperview().inset(14)
            })
        }
    }
    
    func bake() {
        if currentStyle != toast.style {
            makeViewIfNeeded()
            if currentStyle.isForever, !toast.style.isForever, toast.timeout == nil {
                Common.Delay.execution(delay: toast.defaultTimeout + 0.5) {
                    [weak self] in
                    let operation = self?.toast.operation as? CancellableBlockOperation
                    operation?.finish()
                }
            }
            currentStyle = toast.style
        }
        switch toast.style {
        case .spinner:
            activityView?.startLoading()
        case .success:
            activityView?.completeLoading(.success)
        case .alert:
            activityView?.completeLoading(.alert)
        case .fatal:
            activityView?.completeLoading(.failed)
        case let .image(image):
            imageView?.image = image
        }
        if let text = toast.text {
            label?.text = text
        } else if let text = toast.attributedText {
            label?.attributedText = text
        }
        superview?.layoutIfNeeded()
    }
    
    func animateShow() {
        toast.appearing?()
        toast.appearing = nil
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        alpha = 0
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 1
        })
        if let activityView = activityView {
            activityView.alpha = 0
            activityView.transform = transform
            UIView.animate(withDuration: 0.15, delay: 0.1, options: .curveEaseInOut, animations: {
                activityView.alpha = 1
                activityView.transform = .identity
            })
        }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: [.curveEaseInOut], animations: {
            self.transform = .identity
        })
    }
    
    func animateDismiss() {
        if self.superview == nil {
            return
        }
        toast.completion?()
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { [weak self] (_) in
            self?.removeFromSuperview()
        }
    }
    
}
