//
//  CollectionView.swift
//  quick
//
//  Created by suyikun on 2021/6/30.
//

import Foundation
import IGListKit
import IGListDiffKit
import common

class CollectionView: UICollectionView, UIGestureRecognizerDelegate {
    weak var panDelegate: UIGestureRecognizerDelegate?
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let delegate = panDelegate {
            if let result = delegate.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
                return result
            }
        }
        return false
    }
}

class EmptyCollectionCell: UICollectionViewCell, ListBindable {
    func bindViewModel(_ viewModel: Any) {}
}

extension Keys {
    struct UICollectionView {
        static var sectionControllerForModel = "cellFromModel"
        static var registeredSectionControllers = "registeredSectionControllers"
        static var sectionDataSource = "sectionDataSource"
    }
}

extension UICollectionView {
    
    typealias SectionControllerClosure = () -> ListSectionController
    
    class SectionControllerMapper {
        fileprivate(set) var modelClass: AnyClass
        var controllerClosure: SectionControllerClosure
        
        init(modelClass: AnyClass, controllerClosure: @escaping SectionControllerClosure) {
            self.modelClass = modelClass
            self.controllerClosure = controllerClosure
        }
    }
    
    var sectionControllerForModel: ((Any) -> ListSectionController?)? {
        get {
            property(for: &Keys.UICollectionView.sectionControllerForModel) as? (Any) -> ListSectionController?
        }
        set {
            setProperty(for: &Keys.UICollectionView.sectionControllerForModel, newValue, policy: .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
//    var sectionDataSource: CollectionViewSectionDataSource? {
//        get {
//            property(for: &Keys.UICollectionView.sectionDataSource) as? CollectionViewSectionDataSource
//        }
//        set {
//            setProperty(for: &Keys.UICollectionView.sectionDataSource, newValue, policy: .OBJC_ASSOCIATION_RETAIN)
//        }
//    }
    
    var registeredSectionControllers: [SectionControllerMapper] {
        get {
            guard let controllers = property(for: &Keys.UICollectionView.registeredSectionControllers) as? [SectionControllerMapper] else {
                let controllers = [SectionControllerMapper]()
                setProperty(for: &Keys.UICollectionView.registeredSectionControllers, controllers)
                return controllers
            }
            return controllers
        }
        set {
            setProperty(for: &Keys.UICollectionView.registeredSectionControllers, newValue)
        }
    }
    
    final func controllerMapper(for model: Any) -> SectionControllerMapper? {
        guard let model = model as? NSObjectProtocol else {
            return nil
        }
        var matches = [SectionControllerMapper]()
        for k in registeredSectionControllers {
            if model.isKind(of: k.modelClass) {
                matches.append(k)
            }
        }
        return matches.sorted { $0.modelClass.isSubclass(of: $1.modelClass) }.first
    }
    
    final func sectionController<T: Any>(for model: T) -> ListSectionController {
        if let controller = sectionControllerForModel?(model) {
            return controller
        }
        if let controllerClosure = controllerMapper(for: model)?.controllerClosure {
            return controllerClosure()
        }
        return ListSingleSectionController<T, EmptyCollectionCell>()
    }
    
    final func register<T: ListSectionController, O: NSObjectProtocol>(controller: T.Type, for model: O.Type) {
        if let model = model as? NSObject.Type {
            registeredSectionControllers += [SectionControllerMapper(modelClass: model.classForCoder(), controllerClosure: { () -> ListSectionController in
                return controller.init()
            })]
        }
    }
    
    final func register<T: UICollectionViewCell & ListBindable, O: NSObjectProtocol>(singleCell: T.Type, for model: O.Type) {
        register(controller: ListSingleSectionController<O, T>.self, for: O.self)
    }
    
    final func register<O: NSObjectProtocol>(closure: @escaping SectionControllerClosure, for model: O.Type) {
        if let model = model as? NSObject.Type {
            registeredSectionControllers += [SectionControllerMapper(modelClass: model.classForCoder(), controllerClosure: closure)]
        }
    }
}
