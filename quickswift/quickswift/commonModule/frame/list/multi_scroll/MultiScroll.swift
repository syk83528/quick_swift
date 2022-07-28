//
//  MultiScroll.swift
//  quick
//
//  Created by suyikun on 2021/6/27.
//

import Foundation
import YTPageController

enum ScrollState: Int {
    case pending, scrolling, ended
}

protocol ScrollStateful: AnyObject {
    var scrollView: UIScrollView { get }
    var scrollState: ScrollState { get }
    var lastContentOffset: CGPoint { get set }
}

enum ViewPortState: Int {
    case begin, middle, end
}

protocol ViewPortStateful: AnyObject {
    var viewPortState: ViewPortState { get }
}

class MultiScrollViewController: UIViewController {
    var shouldHideShadow: Bool = false
    var scrollView = UIScrollView()
    var pager = YTPageController()
    var scrollState: ScrollState = .pending
    var lastContentOffset: CGPoint = .zero
    var currentViewController: ScrollStateful? {
        pager.currentViewController as? ScrollStateful
    }
    var resetAfterLayout = true
    var snapbackEnabled = true
    
    enum ScrollDirection: Int {
        case pending, up, down
    }
    private var lastDirection: ScrollDirection = .pending
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        scrollView.clipsToBounds = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.add(to: view)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(view.pin.safeArea.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

extension MultiScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }
        
        let offSetY = scrollView.contentOffset.y
        if offSetY >= scrollView.contentSize.height - scrollView.frame.height {// 只要到达顶部就属于 end 状态
            scrollState = .ended
            scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.frame.height
        } else if offSetY > 0 {// 中间的任意状态都属于 scrolling 状态
            scrollState = .scrolling
        } else if offSetY <= 0 {// 只要小于等于0就属于 pending 状态
            scrollState = .pending
            scrollView.contentOffset.y = 0
        }
        
        if scrollView.contentOffset.y > lastContentOffset.y {
            lastDirection = .up
        } else {
            lastDirection = .down
        }
        lastContentOffset = scrollView.contentOffset
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard snapbackEnabled == true else { return }

        if velocity.y <= .min, scrollState == .scrolling {
            if lastDirection == .up {
                targetContentOffset.assign(repeating: CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.frame.height), count: 1)
            } else {
                targetContentOffset.assign(repeating: .zero, count: 1)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard snapbackEnabled == true else { return }
        
//        if scrollState == .scrolling {
//            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
//            if lastDirection == .up {
//                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.frame.height), animated: true)
//            } else {
//                scrollView.setContentOffset(.zero, animated: true)
//            }
//        }
    }
}
