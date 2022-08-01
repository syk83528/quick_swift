//
//  SectionControllers.swift
//  quick
//
//  Created by suyikun on 2021/7/1.
//

import Foundation
import IGListKit

protocol AnySelectable {
    var didSelectModel: ((Any) -> Void)? { get set }
}

class ListSingleSectionController<Model, Cell: UICollectionViewCell>: ListSectionController {
    override init() {
        super.init()
    }
    
    var model: Model?
    
    func layoutConfig(inset: UIEdgeInsets = .zero, minimumLineSpacing: CGFloat = 0, minimumInteritemSpacing: CGFloat = 0) -> Self {
        self.inset = inset
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
        return self
    }
    
    override func numberOfItems() -> Int { 1 }
    
    override func sizeForItem(at index: Int) -> CGSize {
        if let model = model as? LayoutCachable {
            return model.cellSize
        } else if let model = Model.self as? LayoutCachable.Type {
            return model.cellSize
        } else if let model = Cell.self as? LayoutCachable.Type {
            return model.cellSize
        } else {
            return .zero
        }
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        if let source = Cell.reusableSource {
            switch source {
            case .cls:
                cell = collectionContext?.dequeueReusableCell(of: Cell.self, for: self, at: index)
            case .nib:
                cell = collectionContext?.dequeueReusableCell(withNibName: Cell.nibName, bundle: Cell.nibBundle, for: self, at: index)
            case .storyboard:
                cell = collectionContext?.dequeueReusableCellFromStoryboard(withIdentifier: Cell.identifier, for: self, at: index)
            }
        } else {
            cell = collectionContext?.dequeueReusableCell(of: Cell.self, for: self, at: index)
        }
        guard let cell = cell else {
            fatalError("cell is nil")
        }
        if let cell = cell as? ListBindable, let model = model {
            cell.bindViewModel(model)
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        model = object as? Model
    }
    
    override func didSelectItem(at index: Int) {
        log("选中了")
    }
    
}
