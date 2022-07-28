//
//  TableProvider.swift
//  quick
//
//  Created by suyikun on 2021/7/3.
//

import Foundation
import IGListKit
import ReactiveCocoa
import ReactiveSwift
import DZNEmptyDataSet
import MJRefresh
import common

enum NetRequestType:CaseIterable {
    case refresh
    case loadMore
}

protocol EmptyProvider: PropertyStoring {
    var emptyView: UIView? { get }
    var emptyViewVerticalOffset: CGFloat { get set }
    /// 是否需要显示 EmptyView
    var shouldDisplayEmptyView: Bool { get set }
    /// 外部使用 `shouldDisplayEmptyView` 来控制是否显示, CollectionViewController/TableViewController 内部使用，处理是否需要显示，优先级比 shouldDisplayEmptyView 低
    var internalShouldDisplayEmptyView: Bool { get set }
    func refreshEmptyStatus()
}

enum DataSourceUIUpdateAction: Equatable {
    case refresh
    case loadMore
    case reload(_ model: Any? = nil, _ animated: Bool = false)
    case error(_ error: Error? = nil)
    
    static func == (lhs: DataSourceUIUpdateAction, rhs: DataSourceUIUpdateAction) -> Bool {
        switch (lhs, rhs) {
        case (.refresh, .refresh),
             (.loadMore, .loadMore),
             (.reload, .reload),
             (.error, .error):
            return true
        default:
            return false
        }
    }
}

protocol TableProvider: UIViewController {
    associatedtype DataType: DiffableJSON
    var tableViewController: TableViewController<DataType> { get }
    var tableView: TableView { get }
}

fileprivate var tableViewControllerKey: UInt8 = 0
extension TableProvider {
    var tableViewController: TableViewController<DataType> {
        get {
            associatedObject(&tableViewControllerKey) { TableViewController<DataType>() }
        }
        set {
            setAssociatedObject(&tableViewControllerKey, newValue)
        }
    }
    
    var tableView: TableView {
        tableViewController.tableView
    }
    
    var list:[DataType] {
        get {
            tableViewController.list
        }
        set {
            tableViewController.list = newValue
        }
    }
}

enum HeaderFooterType: Int {
    case header, footer
}
enum HeaderFooterProvideType: Int {
    case view, height
}
class TableViewController<T: DiffableJSON>: UIViewController, ScrollStateful, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIGestureRecognizerDelegate {
    //MARK:- --------------------------------------UI
    var tableViewStyle: UITableView.Style {
        .plain
    }
    var tableView: TableView!
    //MARK:- --------------------------------------ScrollStateful
    var scrollView: UIScrollView { tableView }
    var lastContentOffset: CGPoint = .zero
    var scrollState: ScrollState = .pending
    //MARK:- --------------------------------------Data
    var list: [T] = []
    /// 是否第一次请求回来
    var isFirstRequestRespond: Bool = false
    var canEditClosure: ((T, IndexPath) -> Bool)?
    var tableHeaderFooterProvider: ((_ section: Int, _ type: HeaderFooterType) -> (UIView?, CGFloat?))?
    var (selectCell, selectCellInput) = Signal<T, Never>.pipe()
    var selectClosure: ((T, IndexPath, TableView) -> ())?
    
    // Empty
    var emptyView: UIView? = EmptyViewInstance.shared.default
    var emptyViewVerticalOffset: CGFloat = -(.navigationBarHeight + 50)
    var internalShouldDisplayEmptyView: Bool = false {
        didSet {
            tableView.reloadEmptyDataSet()
        }
    }
    var shouldDisplayEmptyView: Bool = true {
        didSet {
            refreshEmptyStatus()
        }
    }
    
    // Refresh
    @objc dynamic var shouldLoadMore = false
    @objc dynamic var shouldRefresh = true
    private var page: Int = 1
    
    private weak var p: MultiScrollViewController?
    private var checkP: Bool = false
    
    //MARK:- --------------------------------------System
    init() {
        super.init(nibName: nil, bundle: nil)
        configTable()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func configTable() {
        let t = TableView(frame: .screenBounds, style: tableViewStyle)
        t.panDelegate = self
        tableView = t
        t.dataSource = self
        t.delegate = self
        t.separatorStyle = .none
        t.backgroundColor = .white
        t.separatorColor = .none
        t.alwaysBounceHorizontal = false
        t.alwaysBounceVertical = true
        t.emptyDataSetSource = self
        t.emptyDataSetDelegate = self
        t.add(to: self.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.frame
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        guard let parent = parent else { return }
        
        parent.r.signal(for: #selector(viewWillAppear(_:))).take(duringLifetimeOf: parent).take(duringLifetimeOf: self).do { [weak self] (params) in
            self?.beginAppearanceTransition(true, animated: params.first?.bool ?? false)
        }
        parent.r.signal(for: #selector(viewDidAppear(_:))).take(duringLifetimeOf: parent).take(duringLifetimeOf: self).do { [weak self] (_) in
            self?.endAppearanceTransition()
        }
        parent.r.signal(for: #selector(viewWillDisappear(_:))).take(duringLifetimeOf: parent).take(duringLifetimeOf: self).do { [weak self] (params) in
            self?.beginAppearanceTransition(false, animated: params.first?.bool ?? false)
        }
        parent.r.signal(for: #selector(viewDidDisappear(_:))).take(duringLifetimeOf: parent).take(duringLifetimeOf: self).do { [weak self] (_) in
            self?.endAppearanceTransition()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log("\(Self.self)出现了")
        self.lastContentOffset = scrollView.contentOffset
        guard !checkP else { return }
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
    
//    func request<E: Swift.Error>(_ requestClosure: @escaping (NetRequestType, Int) -> SignalProducer<[T], E>?) {
////        var refreshClosure:
//        for type in NetRequestType.allCases {
//            var shouldExecuteProperty: Property<Bool>
//            switch type {
//            case .refresh:
//                shouldExecuteProperty = Property<Bool>.init(initial: shouldRefresh, then: self.o[\.shouldRefresh])
//            case .loadMore:
//                shouldExecuteProperty = Property<Bool>.init(initial: shouldLoadMore, then: self.o[\.shouldLoadMore])
//            }
//            
//            let action = Action<(), [T], Never>.init(enabledIf: shouldExecuteProperty) { [weak self] _ in
//                guard let self = self else { return .never }
//                
//                let targetPage = type == .refresh ? 1 : self.page + 1
//                return requestClosure(type, targetPage)?.ignoreErrors().on(value: { value in
//                    
//                })
//            }
//            
//            
//        }
//    }
    
    
    
    
    
    
    
    
    //MARK:- --------------------------------------Refresh
//    func feed<E:Swift.Error>(_ requestClosure: @escaping (NetRequestType, Int) -> SignalProducer<[T], E>?) {
//
//        var refreshAction: CocoaAction<Any>?
//        var loadMoreAction: CocoaAction<Any>?
//        for type in NetRequestType.allCases {
//            var shouldExecuteProperty: Property<Bool>
//            switch type {
//            case .refresh:
//                shouldExecuteProperty = Property(initial: shouldRefresh, then: self.o[\.shouldRefresh])
//            case .loadMore:
//                shouldExecuteProperty = Property(initial: shouldLoadMore, then: self.o[\.shouldLoadMore])
//            }
//            let action = Action<(), [T], Never>.init(enabledIf: shouldExecuteProperty) {[weak self] _ in
//                guard let self = self else { return .never}
//                return requestClosure(type, self.page)?.on(failure: {[weak self] e in
//                    self.
//                }, finally: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//
//            }
//
//
//
//
//            let action = Action<(), [T], Never>(enabledIf: shouldExecuteProperty) { [weak self] (_) -> SignalProducer<[T], Never> in
//                guard let self = self else {
//                    return .never
//                }
//                let targetPage = type == .refresh ? 1 : self.page + 1
//                return requestClosure(type, targetPage)?.on(failed: {
//                    [weak self] error in
//                    log("error垃~")
////                    self?.updateUIInput.send(value: .error(error))
//                }).ignoreErrors().on(value: {
//                    [weak self] value in
//                    guard let self = self else { return }
//                    switch type {
//                    case .refresh:
//                        self.list = value
//                        self.tableView.reloadData()
//                        self.tableView.mj_header?.endRefreshing()
//                    case .loadMore:
//                        self.list += value
//                        self.tableView.reloadData()
//                        self.tableView.mj_footer?.endRefreshing()
//                    }
//                }) ?? .never
//            }
//            let executable = action.executable
//            executable.isUserEnabled = shouldExecuteProperty
//            switch type {
//            case .refresh:
//                self.tableView.mj_header = MJRefreshNormalHeader { [weak self] in
//                    guard let self = self, let header = self.tableView.mj_header else { return }
//                    executable.execute(header)
//                    }.autoChangeTransparency(true)
//            case .loadMore:
//                self.tableView.mj_footer = MJRefreshBackFooter { [weak self] in
//                    guard let self = self, let footer = self.tableView.mj_footer else { return }
//                    executable.execute(footer)
//                    }.autoChangeTransparency(true)
//            }
//        }
//
//
//        tableView.refreshAction = refreshAction
//        tableView.loadMoreAction = loadMoreAction
//    }
    //MARK:- --------------------------------------Empty
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
        self.emptyViewVerticalOffset.w
    }
    
    func refreshEmptyStatus() {
        if self.shouldDisplayEmptyView {
            self.internalShouldDisplayEmptyView = list.isEmpty
        } else {
            self.internalShouldDisplayEmptyView = false
        }
    }
    
    //MARK:- --------------------------------------Gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == p?.scrollView.panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
    //MARK:- --------------------------------------TableDataSource&TableDelegate
    func reloadData() {
        self.tableView.reloadData()
        self.refreshEmptyStatus()
    }
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = list[safe: indexPath.row],
              let cell = tableView.cell(for: model, indexPath: indexPath) else {
            return UITableViewCell()
        }
        
        (cell as? ListBindable)?.bindViewModel(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if list.count == 0, let modelType = T.self as? LayoutCachable.Type {
            // 为 skeleton做准备
            return modelType.cellHeight
        }
        guard let model = list[safe: indexPath.row] else {
            if let (_, _, cls) = tableView.registeredIdentifiers.first, let cachable = cls as? LayoutCachable.Type {
                // 从注册 cell 取静态cellHeight
                return cachable.cellHeight
            }
            return tableView.rowHeight
        }
        if let model = model as? LayoutCachable {// 从 model 取
            return model.cellHeight
        }
        if let (_, _, cls) = tableView.classAndIdentifier(for: model), let cachable = cls as? LayoutCachable.Type {// 从 model 静态取
            return cachable.cellHeight
        }
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 如果tablviewController 的 parent 实现了UITableViewDelegate,并且能够响应didSelectRowAt方法
        if let delegate = self.parent as? UITableViewDelegate,
           delegate.responds(to: #selector(tableView(_:didSelectRowAt:))) {
            delegate.tableView?(tableView, didSelectRowAt: indexPath)
            return
        }
        if let model = list[safe: indexPath.row] {
            selectCellInput.send(value: model)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let delegate = self.parent as? UITableViewDelegate {
            delegate.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let delegate = self.parent as? UITableViewDelegate {
            delegate.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let model = list[safe: indexPath.row] else { return false }
        if let delegate = self.parent as? UITableViewDataSource,
           delegate.responds(to: #selector(tableView(_:canEditRowAt:))) {
            return delegate.tableView?(tableView, canEditRowAt: indexPath) ?? false
        }
        if let can = canEditClosure?(model, indexPath) {
            return can
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let delegate = self.parent as? UITableViewDelegate,
           delegate.responds(to: #selector(tableView(_:heightForHeaderInSection:))) {
            return delegate.tableView?(tableView, heightForHeaderInSection: section) ?? .min
        }
        if let height = tableHeaderFooterProvider?(section, .header).1 {
            return height
        }
        return .min
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let delegate = self.parent as? UITableViewDelegate,
           delegate.responds(to: #selector(tableView(_:heightForFooterInSection:))) {
            return delegate.tableView?(tableView, heightForFooterInSection: section) ?? .min
        }
        if let height = tableHeaderFooterProvider?(section, .footer).1 {
            return height
        }
        return .min
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let delegate = self.parent as? UITableViewDelegate,
           delegate.responds(to: #selector(tableView(_:viewForHeaderInSection:))) {
            return delegate.tableView?(tableView, viewForHeaderInSection: section)
        }
        if let view = tableHeaderFooterProvider?(section, .header).0 {
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let delegate = self.parent as? UITableViewDelegate,
           delegate.responds(to: #selector(tableView(_:viewForFooterInSection:))) {
            return delegate.tableView?(tableView, viewForFooterInSection: section)
        }
        if let view = tableHeaderFooterProvider?(section, .footer).0 {
            return view
        }
        return nil
    }
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
}

extension TableViewController {
    @discardableResult
    func moveTo(_ viewController: UIViewController) -> Self {
        willMove(toParent: viewController)
        viewController.view.addSubview(tableView)
        tableView.frame = viewController.view.bounds
        viewController.addChild(self)
        didMove(toParent: viewController)
        return self
    }
}
