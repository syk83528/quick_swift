//
//  CollectionViewCell.swift
//  quick
//
//  Created by suyikun on 2021/7/1.
//

import Foundation
import FlexLayout
import IGListKit

class CollectionViewCell: UICollectionViewCell, ListBindable {
    
    let flexRootContainer = UIView()
    var rootFlex: Flex {
        flexRootContainer.flex
    }
    
    var flexLayoutMode: Flex.LayoutMode {
        .fitContainer
    }
    var disableAutoSetNeedsLayout: Bool {
        false
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addContainer()
        autoRelayoutIfAvailable()
        commonInit()
        allEvents()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        addContainer()
        autoRelayoutIfAvailable()
        commonInit()
        allEvents()
    }
    
    private func addContainer() {
        flexRootContainer.add(to: contentView)
    }
    
    /// 如果没有实现 ListBindable 协议，则不会自动 layoutIfNeeded
    private func autoRelayoutIfAvailable() {
        if disableAutoSetNeedsLayout { return }
        if let bindable = self as? ListBindable {
            r.signal(for: #selector(bindable.bindViewModel(_:))).take(duringLifetimeOf: self).observeValues { [weak self] (_) in
                guard let self = self else { return }
                self.setNeedsLayout()
            }
        }
    }
    
    /// from: CollectionViewCell(it's not to do anything...)
    func commonInit() { }
    
    func allEvents() { }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flexRootContainer.pin.all()
        flexRootContainer.flex.layout(mode: flexLayoutMode)
    }
    
    func bindViewModel(_ viewModel: Any) {}
}
