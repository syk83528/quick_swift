//
//  empty_instance.swift
//  quickswift
//
//  Created by suyikun on 2022/7/28.
//

import Foundation
import UIKit
import ReactiveCocoa
import ReactiveSwift
import common

//import ViewAnimator

class EmptyView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    let flexRootContainer = UIView()
    private let emptyImageView = UIImageView().then({
        $0.contentMode = .scaleAspectFill
    })
    private let tipsLabel = UILabel().then({
        $0.textColor = .hex(0xC0C0C0)
        $0.fontSize = 14
        $0.numberOfLines = 0
        $0.textAlignment = .center
//        $0.autoDirty()
    })
    private var __tips: String? {
        didSet {
            tipsLabel.text = __tips
            tipsLabel.textLineSpacing = 4
            tipsLabel.flex.markDirty()
            setNeedsLayout()
        }
    }
    @discardableResult
    func tips(_ value: String?) -> EmptyView {
        self.__tips = value
        return self
    }
    private var __emptyImage: UIImage? {
        didSet {
            emptyImageView.image = __emptyImage
            emptyImageView.flex.markDirty()
            setNeedsLayout()
        }
    }
    @discardableResult
    func emptyImage(_ image: UIImage?) -> EmptyView {
        self.__emptyImage = image
        return self
    }
    
    // 负数向上，正数向下
    var offsetY: CGFloat = 0
    
    var retryButtonTitle: String? = nil {
        didSet {
            retryButton.setTitle(retryButtonTitle, for: .normal)
            retryButton.flex.display(retryButtonTitle != nil ? .flex : .none)
            retryButton.flex.markDirty()
            setNeedsLayout()
        }
    }
    
    // 设计图是什么尺寸，就给什么尺寸就行，自动处理了大小屏幕的 width
    var retryButtonWidth: CGFloat = 120 {
        didSet {
            retryButton.flex.width(retryButtonWidth.w)
            retryButton.flex.markDirty()
            setNeedsLayout()
        }
    }
    
    lazy var retryTouchUpInside: Signal<UIButton, Never> = {
        retryButton.r.touchUpInside
    }()
    
    private let retryButton = UIButton()
    private weak var previousSuperview: UIView?
    
    private func commonInit() {
        flexRootContainer.add(to: self)
        flexRootContainer.flex.alignItems(.center).marginHorizontal(Const.hMargin).define { (flex) in
            flex.addItem(emptyImageView)
            flex.addItem(tipsLabel).marginTop(6)
            flex.addItem(retryButton).marginTop(50).height(48).width(retryButtonWidth.w).display(retryButtonTitle != nil ? .flex : .none)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        flexRootContainer.size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if superview == nil { return }
        flexRootContainer.pin.horizontally().vCenter().marginBottom(offsetY)
        flexRootContainer.flex.layout(mode: .adjustHeight)
        invalidateIntrinsicContentSize()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview == nil || (previousSuperview != nil && superview == previousSuperview) { return }
        previousSuperview = superview
        appearsAnimate()
    }
    private func appearsAnimate() {
//        subviews.animate(with: .vector(dx: 0, dy: 30))
    }
}

struct EmptyViewInstance {
    
    static var shared = EmptyViewInstance()
    
    var `default`: EmptyView {
        EmptyView().emptyImage(UIImage(named: "empty_feed")).tips("暂无数据")
    }
    
    var blackList: EmptyView {
        EmptyView().emptyImage(UIImage(named: "general_empty_blacklist")).tips("还没有黑名单哦~")
    }
    
    var postNearby: EmptyView {
        EmptyView().emptyImage(UIImage(named: "empty_locating")).tips("获取位置信息失败\n请到 “设置＞隐私＞定位服务” 中开启定位服务").then({
            $0.retryButtonTitle = "开启定位"
            $0.retryButtonWidth = 170
        })
    }
    ///师徒-徒弟
    var student: EmptyView {
        EmptyView().emptyImage(UIImage(named: "empty_feed")).tips("好惨一\(Const.friend)，连个徒弟都没有～").then({
            $0.retryButtonTitle = "去收个小徒弟"
            $0.retryButtonWidth = 122
        })
        
    }
    
    ///师徒-师傅
    var teacher: EmptyView {
        EmptyView().emptyImage(UIImage(named: "empty_feed")).tips("好惨一\(Const.friend)，连个师傅都没有～")
    }

   /// 圈子列表
   var moments: EmptyView {
        EmptyView().emptyImage(UIImage(named: "empty_feed")).tips("去圈子列表发现更多圈子吧").then({
           $0.retryButtonTitle = "去看看"
           $0.retryButtonWidth = 170
        })
   }
    
}
