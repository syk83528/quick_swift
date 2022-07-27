//
//  StickyBar.swift
//  spsd
//
//  Created by Wildog on 2/19/20.
//  Copyright © 2020 Wildog. All rights reserved.
//

import UIKit
import MarqueeLabel
import common

class Baguette: Bakable {
    enum Layout: Int {
        case truncate, multilines, marquee
    }
    
    let haptic: Baker.Haptic
    let interaction: Baker.Interaction = .none
    let background: Baker.Background = .none
    let position: Baker.Position = .top
    let delay: TimeInterval?
    let layout: Layout
    let tapAction: (() -> Bool)?
    private(set) var timeout: TimeInterval? // 默认会根据内容长度算，spinner默认为永久
    
    let bakingView: BakingView.Type = BaguetteView.self
    
    var behavior: Baker.Behavior
    weak var operation: Operation?
    var completion: (() -> Void)?
    var appearing: (() -> Void)?
    
    var style: Baker.Style {
        didSet {
            if let styleChangeBlock = styleChangeBlock {
                styleChangeBlock(style)
            } else {
                guard !oldValue.strictEqual(to: style),
                    oldValue.isForever || (timeout ?? 0 > 1000), !style.isForever else { return }
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
         action: (() -> Bool)? = nil, layout: Layout = .truncate,
         behavior: Baker.Behavior = .queue(.high), haptic: Baker.Haptic = .none,
         timeout: TimeInterval? = nil, delay: TimeInterval? = nil) {
        self.text = text
        self.attributedText = attributedText
        if text == nil, attributedText == nil {
            self.text = ""
        }
        self.style = style
        self.layout = layout
        self.behavior = behavior
        self.haptic = haptic
        self.timeout = timeout
        self.delay = delay
        self.tapAction = action
    }
    
    static func dismiss(currentOnly: Bool = true) {
        if currentOnly {
            Baker.shared.queues[.top]?.cancelRunningOperations()
        } else {
            Baker.shared.queues[.top]?.cancelAllOperations()
        }
    }
}

class BaguetteView: UIView, BakingView {
    var colorView = UIView()
    let label = MarqueeLabel().then {
        $0.font = .medium(16)
        $0.textColor = .white
    }
    let iconContainer = UIView().then {
        $0.size = .init(width: 26, height: 26)
    }
    var iconView: UIImageView?
    var activityView: UIActivityIndicatorView?
    var currentStyle: Baker.Style
    let baguette: Bakable

    required init(with: Bakable) {
        baguette = with
        currentStyle = with.style
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        clipsToBounds = true
        label.isUserInteractionEnabled = false
        
        colorView.add(to: self)
        iconContainer.add(to: self)
        label.add(to: self)

        makeViewIfNeeded()
        
        guard let baguette = with as? Baguette else { return }
        r.tap.do {
            if baguette.tapAction?() == false {
                return
            }
            if baguette.style != .spinner {
                let operation = baguette.operation as? CancellableBlockOperation
                operation?.finish()
            }
        }
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipe.direction = .up
        NSObject.ignoreError { () -> Any? in
            swipe.setValue(10, forKey: "minimumPrimaryMovement")
        }
        addGestureRecognizer(swipe)

        label.snp.makeConstraints { (m) in
            m.left.equalToSuperview().inset(41)
            m.right.lessThanOrEqualToSuperview().inset(22)
            if baguette.layout == .multilines {
                m.height.greaterThanOrEqualTo(20)
                m.top.bottom.equalToSuperview().inset(10)
            } else {
                m.height.equalTo(40)
                m.top.bottom.equalToSuperview()
            }
        }
        if baguette.layout == .marquee {
            label.holdScrolling = true
            label.type = .continuous
            label.speed = .duration(min(CGFloat(baguette.timeout ?? baguette.defaultTimeout), 8) / 1.5)
            label.fadeLength = 8
            label.trailingBuffer = 20
        } else {
            if baguette.layout == .truncate {
                label.lineBreakMode = .byTruncatingTail
            } else if baguette.layout == .multilines {
                label.numberOfLines = 0
            }
            label.labelize = true
        }

        baguette.styleChangeBlock = {
            [weak self] (_) in
            UIView.animate(withDuration: 0.25) {
                self?.bake()
            }
        }
        baguette.textChangeBlock = {
            [weak self] (text) in
            guard let self = self else { return }
            self.label.text = text
            if text == nil {
                self.label.attributedText = self.baguette.attributedText
            }
            UIView.animate(withDuration: 0.25) {
                self.superview?.layoutIfNeeded()
            }
        }
        baguette.attributedTextChangeBlock = {
            [weak self] (text) in
            guard let self = self else { return }
            self.label.attributedText = text
            if text == nil {
                self.label.text = self.baguette.text ?? ""
            }
            UIView.animate(withDuration: 0.25) {
                self.superview?.layoutIfNeeded()
            }
        }
        baguette.progressChangeBlock = {
            [weak self] (progress) in
            Common.Queue.main {
                guard let colorView = self?.colorView else { return }
                UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                    colorView.snp.remakeConstraints { (m) in
                        m.left.top.bottom.equalToSuperview()
                        m.width.equalToSuperview().multipliedBy(progress ?? 0)
                    }
                    self?.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func swiped() {
        if baguette.style != .spinner {
            let operation = baguette.operation as? CancellableBlockOperation
            operation?.finish()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let baguette = self.baguette as? Baguette else { return }
        switch baguette.layout {
        case .truncate, .marquee:
            layer.cornerRadius = bounds.size.height / 2
        case .multilines:
            layer.cornerRadius = 20
        }
        colorView.layer.cornerRadius = layer.cornerRadius
        if bounds.size.height <= 44 {
            iconContainer.center = .init(x: 20, y: bounds.size.height / 2)
        } else {
            iconContainer.center = .init(x: 20, y: 24)
        }
    }
    
    func makeViewIfNeeded() {
        switch baguette.style {
        case .spinner:
            iconView?.removeFromSuperview()
            if activityView == nil {
                activityView = UIActivityIndicatorView(style: .white)
            }
            activityView?.add(to: iconContainer)
            activityView?.snp.remakeConstraints({ (m) in
                m.center.equalToSuperview()
            })
        default:
            activityView?.removeFromSuperview()
            if iconView == nil {
                iconView = UIImageView()
            }
            iconView?.add(to: iconContainer)
            iconView?.snp.remakeConstraints({ (m) in
                m.center.equalToSuperview()
            })
        }
        var progress = self.baguette.progress ?? 0
        if baguette.style != .spinner {
            progress = 1
        }
        colorView.snp.remakeConstraints { (m) in
            m.left.top.bottom.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(progress)
        }
    }
    
    func bake() {
        if !currentStyle.strictEqual(to: baguette.style) {
            makeViewIfNeeded()
            if currentStyle.isForever != baguette.style.isForever
                || ((baguette.timeout ?? 0) > 1000 && !baguette.style.isForever) {
                Common.Delay.execution(delay: baguette.defaultTimeout + 0.5) {
                    [weak self] in
                    let operation = self?.baguette.operation as? CancellableBlockOperation
                    operation?.finish()
                }
            }
            currentStyle = baguette.style
        }
        switch baguette.style {
        case .spinner:
            backgroundColor = .hex(0x7E858C, 0.85)
            activityView?.startAnimating()
        default:
            backgroundColor = .clear
            iconView?.image = baguette.style.baguetteIcon
        }
        colorView.backgroundColor = baguette.style.baguetteColor.alpha(0.85)
        if let text = baguette.text {
            label.text = text
        } else if let text = baguette.attributedText {
            label.attributedText = text
        }
        superview?.layoutIfNeeded()
    }
    
    func animateShow() {
        baguette.appearing?()
        baguette.appearing = nil
        transform = CGAffineTransform(translationX: 0, y: -Screen.height / 2)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [.curveEaseInOut], animations: {
            self.transform = .identity
        }, completion: { [weak self] _ in
            self?.label.holdScrolling = false
        })
    }
    
    func animateDismiss() {
        if self.superview == nil {
            return
        }
        baguette.completion?()
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: -self.frame.y - 60)
        }) { [weak self] (_) in
            self?.removeFromSuperview()
        }
    }
}

fileprivate extension Baker.Style {
    var baguetteIcon: UIImage? {
        switch self {
        case .success:
            return UIImage(named: "baguette_success")
        case .alert:
            return UIImage(named: "baguette_alert")
        case .fatal:
            return UIImage(named: "baguette_error")
        case let .image(image):
            return image
        default:
            return nil
        }
    }
    
    var baguetteColor: UIColor {
        switch self {
        case .success:
            return .hex(0x43A7E0)
        case .alert:
            return .hex(0xE47E30)
        case .fatal:
            return .hex(0xF1453D)
        case .spinner:
            return .hex(0x39CA74)
        default:
            return .hex(0x43A7E0)
        }
    }
}
