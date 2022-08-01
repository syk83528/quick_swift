//
//  BindingSectionController.swift
//  spsd
//
//  Created by 未来 on 2020/1/8.
//  Copyright © 2020 Wildog. All rights reserved.
//

import UIKit
import IGListKit

/**
 >> 最优的 BindingSectionController 使用方案：
 1. 子类只需要实现 `viewModels(for object: Any) -> [ListDiffable]`
 2. 每一个 `viewModel` 继承一下 `CellTypeReturnable` 协议，并实现 `var cellType: BindableCollectionViewCell.Type`
 3. 没有了...
 
 -------------------------------------------
 >> 手动处理 viewModel 与 对应 Cell 的方案:
 1. 子类需要实现 `viewModels(for object: Any) -> [ListDiffable]` 和 `cellTypesForViewModel(viewModel: Any, at index: Int) -> BindableCollectionViewCell.Type`
 2. 在 `cellTypesForViewModel` 中手动判断一下 `viewModel` 并返回对应的 `Cell.Type`
 3. 也没有了, 就是 cellTypesForViewModel 里面的逻辑写的有点烦...
 */

// ListBindingSectionControllerSelectionDelegate
class BindingSectionController<DataType: DiffableJSON>: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource {
    
    var dummy: DataType = DataType()
    
    var isSkeletoning: Bool = false
    var skeletonViews: [UIView]  = []
    var listDiffables: [ListDiffable] = []
    lazy var skeletonCellTypes: [UICollectionViewCell.Type] = {
        let vm = viewModels(for: dummy)
        return vm.compactMap({ ($0 as? CellTypeReturnable)?.cellType })
    }()
    
    var data: DataType? {
        object as? DataType
    }
    
    override init() {
        super.init()
        
        dataSource = self
    }
    
    func update(animated: Bool = true, updates: ((_ value: DataType) -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        guard let object = object as? DataType else {
            update(animated: animated, completion: completion)
            return }
        updates?(object)
        update(animated: animated, completion: completion)
    }
    
    /// subclass
    func viewModels(for object: Any) -> [ListDiffable] {
        []
    }
    /// subclass
    func configureCell(_ cell: UICollectionViewCell & ListBindable, viewModel: Any, at index: Int) { }
    
    func createSkeletonViews() {
        _ = viewModels(for: dummy)
    }
    /// 放到子类的 viewModels(for:) 中，defer 一下，把获取到的 results 设置 给 listDiffables, 然后调用这个方法
    func makeSkeletonViews() {
        if isSkeletoning {
            // make skeleton views
            let skeletonCells = listDiffables.compactMap({ ($0 as? CellTypeReturnable)?.cellType.init() })
            let cellCaches = listDiffables.compactMap({ $0 as? LayoutCachable })
            
            if skeletonCells.count == cellCaches.count {
                for (idx, skeletonCell) in skeletonCells.enumerated() {
                    skeletonCell.size = cellCaches[idx].cellSize
                    skeletonCell.bindViewModel(listDiffables[idx])
                    skeletonCell.isUserInteractionEnabled = false
                }
                skeletonViews = skeletonCells
            } else {
                llog("the skeletonCells.count is not equal to cellCaches.count")
            }
        }
    }
    
    func cellTypesForViewModel(viewModel: Any, at index: Int) -> (UICollectionViewCell & ListBindable).Type {
        guard let viewModel = viewModel as? CellTypeReturnable else {
            llog("the cell type is nil, your viewModel must implement `CellTypeReturnable` and return `CellType` and `static var cellType`.")
            return EmptyCollectionCell.self
        }
        return viewModel.cellType
    }
    func cellForViewModel(viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        let cellType = cellTypesForViewModel(viewModel: viewModel, at: index)
        if let cell = collectionContext?.reusable(cellType, for: self, at: index) as? (UICollectionViewCell & ListBindable) {
            self.configureCell(cell, viewModel: viewModel, at: index)
            return cell
        }
        return EmptyCollectionCell()
    }
    func sizeForViewModel(viewModel: Any, at index: Int) -> CGSize {
        guard let viewModel = viewModel as? LayoutCachable else {
            llog("the cell size is zero, your viewModel must implement `LayoutCachable` and return `cellSize`.")
            return .zero
        }
        return viewModel.cellSize
    }
    
    // binding section controller data source
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        viewModels(for: object)
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        cellForViewModel(viewModel: viewModel, at: index)
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        sizeForViewModel(viewModel: viewModel, at: index)
    }
    
    // ListBindingSectionControllerSelectionDelegate
//    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didSelectItemAt index: Int, viewModel: Any) {
//
//    }
//
//    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didDeselectItemAt index: Int, viewModel: Any) {
//
//    }
//
//    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didHighlightItemAt index: Int, viewModel: Any) {
//
//    }
//
//    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didUnhighlightItemAt index: Int, viewModel: Any) {
//
//    }
}
