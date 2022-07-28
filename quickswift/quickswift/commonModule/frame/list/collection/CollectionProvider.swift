//
//  CollectionProvider.swift
//  quick
//
//  Created by suyikun on 2021/6/30.
//

import Foundation
import IGListKit
import DZNEmptyDataSet
import ReactiveSwift

protocol CollectionProvider: UIViewController {
    associatedtype DataType: DiffableJSON
    var customFlowlayout: UICollectionViewFlowLayout? { get }
    var scrollDirection: UICollectionView.ScrollDirection { get }
    var collectionViewController: CollectionViewController<DataType> { get }
    var collectionView: CollectionView { get }
    var list:[DataType] { get }
    var adapter: ListAdapter { get }
}

fileprivate var collectionViewControllerKey: UInt8 = 0
extension CollectionProvider {
    var customFlowlayout: UICollectionViewFlowLayout? {
        nil
    }
    var scrollDirection: UICollectionView.ScrollDirection {
        .vertical
    }
    var collectionViewController: CollectionViewController<DataType> {
        get {
            associatedObject(&collectionViewControllerKey) {
                let layout = customFlowlayout ?? ListCollectionViewLayout(stickyHeaders: false, scrollDirection: scrollDirection, topContentInset: 0, stretchToEdge: false)
                let vc = CollectionViewController<DataType>(layout: layout)
                return vc
            }
        }
        set {
            setAssociatedObject(&collectionViewControllerKey, newValue)
        }
    }
    var collectionView: CollectionView {
        collectionViewController.collectionView
    }
    
    var adapter: ListAdapter {
        collectionViewController.adapt
    }
    var list:[DataType] {
        get {
            collectionViewController.data
        }
        set {
            collectionViewController.data = newValue
        }
    }
    
    func forceReloadData(_ completion: ((Bool) -> Void)? = nil) {
        adapter.reloadData(completion: completion)
    }
}

class CollectionViewController<T: DiffableJSON>: UIViewController,
                                                 UIScrollViewDelegate,
                                                 UICollectionViewDelegateFlowLayout,
                                                 ListAdapterDataSource,
                                                 ListAdapterDelegate,
                                                 DZNEmptyDataSetDelegate,
                                                 DZNEmptyDataSetSource,
                                                 ScrollStateful,
                                                 UIGestureRecognizerDelegate {
    
    
    //MARK:- --------------------------------------infoProperty
    /// ig只有一维数组,  每一个item都是一个section ,  row是sectionController返回的数组
    var data:[T] = []
    /// 搜索的数据
    var searchData: [T] = []
    /// 是否在搜索中
    var isInSearch: Bool = false
    /// 真正的数据
    var currentData: [T] {
        get {
            isInSearch ? searchData : data
        }
    }
    var adapt:ListAdapter!
    var workingRangeSize: Int = 3
    
    var collectionViewLayout: UICollectionViewLayout = UICollectionViewFlowLayout()
    
    var listAdapterUpdater: ListAdapterUpdater? = nil
    
    var (selectCell, selectCellInput) = Signal<T, Never>.pipe()
    var selectClosure: ((T, IndexPath, TableView) -> ())?
    
    //MARK:- ------------ScrollStateful
    var scrollView: UIScrollView {
        self.collectionView
    }
    var scrollState: ScrollState = .pending
    
    var lastContentOffset: CGPoint = .zero
    //MARK: ------------ScrollStateful
    //MARK:- ------------MultiScroll
    private weak var p: MultiScrollViewController?
    private var checkP: Bool = false
    //MARK: ------------MultiScroll
    //MARK:- --------------------------------------UIProperty
    var collectionView: CollectionView!
    
    var emptyView: UIView? = EmptyViewInstance.shared.default
    var emptyViewVerticalOffset: CGFloat = -(.navigationBarHeight + 50)
    var internalShouldDisplayEmptyView: Bool = false {
        didSet {
            collectionView.reloadEmptyDataSet()
        }
    }
    var shouldDisplayEmptyView: Bool = true {
        didSet {
            refreshEmptyStatus()
        }
    }
    //MARK:- --------------------------------------system
//    convenience init(collectionViewLayout layout: UICollectionViewLayout) {
//
//    }
    private init() {
        super.init(nibName: nil, bundle: nil)
        configCollection()
    }
    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
        configCollection()
    }
    
    convenience init(workingRangeSize: Int = 3,
                     layout: UICollectionViewLayout = ListCollectionViewLayout(stickyHeaders: false, scrollDirection: UICollectionView.ScrollDirection.vertical, topContentInset: 0, stretchToEdge: false)) {
        self.init()
        self.workingRangeSize = workingRangeSize
        self.collectionViewLayout = layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    private func configCollection() {
        
        let c = CollectionView(frame: .screenBounds, collectionViewLayout: collectionViewLayout)
        c.panDelegate = self
        collectionView = c
        c.alwaysBounceVertical = true
        c.dataSource = nil
        c.delegate = self
        c.alwaysBounceHorizontal = false
        c.backgroundColor = .clear
        c.emptyDataSetSource = self
        c.emptyDataSetDelegate = self
        
        adapt = ListAdapter(updater: listAdapterUpdater ?? ListAdapterUpdater(), viewController: self, workingRangeSize: workingRangeSize)
        adapt.collectionView = c
        adapt.dataSource = self
        adapt.scrollViewDelegate = self
        adapt.delegate = self
        
        c.add(to: self.view)
    }
    
    func commonInit() {
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        collectionView.frame = self.view.frame
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lastContentOffset = scrollView.contentOffset
        guard checkP else { return }
        checkP = true
        var p = self.parent
        while p != nil, !(p is MultiScrollViewController)  {
            p = p?.parent
        }
        if let p = p as? MultiScrollViewController {
            self.p = p
            enableMultiScroll(self, in: p)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    //MARK: - --------------------------------------Actions
    func applyData(_ completion: (()->())?) {
        adapt.reloadData { _ in
            completion?()
        }
    }
    // MARK: - --------------------------------------Gesture
    private func enableMultiScroll(_ delegate: UIScrollViewDelegate, in container: MultiScrollViewController) {
        guard let delegate = delegate as? NSObject else { return }
        delegate.r.signal(for: #selector(scrollViewDidScroll(_:)))
        .take(duringLifetimeOf: delegate).take(duringLifetimeOf: self)
        .observe(on: QueueScheduler.main)
        .do { [weak self] (params) in
            guard let scrollView = params.first as? UIScrollView,
                let self = self,
                let container = self.p else {
                    return
            }
            if container.scrollState == .scrolling {
                scrollView.contentOffset = self.lastContentOffset
            }
        }
    }
    //MARK:- --------------------------------------net
    //MARK:- --------------------------------------DataSource, Delegate
    //MARK:- --------------------------------------IGListDatasource
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        log("list: \(currentData.count)")
        return currentData
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let controller = collectionView.sectionController(for: object)
        controller.nextResponder = self
        return controller
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        (currentData[safe: indexPath.row] as? LayoutCachable)?.cellSize ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = self.parent as? UICollectionViewDelegateFlowLayout,
           delegate.responds(to: #selector(collectionView(_:didSelectItemAt:))) {
            delegate.collectionView?(collectionView, didSelectItemAt: indexPath)
            return
        }
        if let model = currentData[safe: indexPath.row] {
            selectCellInput.send(value: model)
            return
        }
    }
    // MARK: - --------------------------------------listAdapterDelegate
    func listAdapter(_ listAdapter: ListAdapter, willDisplay object: Any, at index: Int) {
    }
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying object: Any, at index: Int) {
    }
    // MARK: - --------------------------------------Scroll
    //MARK:- --------------------------------------ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let delegate = self.parent as? UIScrollViewDelegate,
           delegate.responds(to: #selector(scrollViewDidScroll(_:))) {
            delegate.scrollViewDidScroll?(scrollView)
        }
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let delegate = self.parent as? UIScrollViewDelegate,
           delegate.responds(to: #selector(scrollViewDidZoom(_:))) {
            delegate.scrollViewDidZoom?(scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let delegate = self.parent as? UIScrollViewDelegate,
           delegate.responds(to: #selector(scrollViewWillBeginDragging(_:))) {
            delegate.scrollViewWillBeginDragging?(scrollView)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let delegate = self.parent as? UIScrollViewDelegate,
           delegate.responds(to: #selector(scrollViewWillEndDragging(_:withVelocity:targetContentOffset:))) {
            delegate.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let delegate = self.parent as? UIScrollViewDelegate,
           delegate.responds(to: #selector(scrollViewDidEndDragging(_:willDecelerate:))) {
            delegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let delegate = self.parent as? UIScrollViewDelegate,
           delegate.responds(to: #selector(scrollViewWillBeginDecelerating(_:))) {
            delegate.scrollViewWillBeginDecelerating?(scrollView)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let delegate = self.parent as? UIScrollViewDelegate,
           delegate.responds(to: #selector(scrollViewDidEndDecelerating(_:))) {
            delegate.scrollViewDidEndDecelerating?(scrollView)
        }
    }
    // MARK: - --------------------------------------Empty
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        nil
    }
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        guard let emptyView = self.emptyView else {
            warning("You should set a value for `emptyView` to display empty placeholder, maybe use `EmptyView` to implement is easier.")
            return UIView()
        }
        return emptyView
    }
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        self.internalShouldDisplayEmptyView
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        true
    }
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        self.emptyViewVerticalOffset.h
    }
    
    func refreshEmptyStatus() {
        if self.shouldDisplayEmptyView {
            self.internalShouldDisplayEmptyView = currentData.isEmpty
        } else {
            self.internalShouldDisplayEmptyView = false
        }
    }
    
    deinit {
        log("💀💀💀------------ \(Self.self)")
    }
}


extension CollectionViewController {
    @discardableResult
    func moveTo(_ viewController: UIViewController) -> Self {
        willMove(toParent: viewController)
        viewController.view.addSubview(collectionView)
        collectionView.frame = viewController.view.bounds
        viewController.addChild(self)
        didMove(toParent: viewController)
        return self
    }
}
