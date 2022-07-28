//
//  TableView.swift
//  quick
//
//  Created by suyikun on 2021/6/28.
//

import Foundation
import common

class TableView: UITableView, UIGestureRecognizerDelegate {
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

extension Keys {
    struct UITableView {
        static var identifierForModel = "identifierFromModel"
        static var cellForModel = "cellFromModel"
        static var registeredIdentifiers = "registeredIdentifiers"
    }
    struct ASTable {
        static var identifierForModel = "identifierFromModel"
        static var cellForModel = "cellFromModel"
        static var registeredIdentifiers = "registeredIdentifiers"
    }
}

public extension UITableView {
    
    var identifierForModel: ((Any) -> String?)? {
        get {
            property(for: &Keys.UITableView.identifierForModel) as? (Any) -> String?
        }
        set {
            setProperty(for: &Keys.UITableView.identifierForModel, newValue, policy: .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var cellForModel: ((UITableView, Any, IndexPath) -> UITableViewCell?)? {
        get {
            property(for: &Keys.UITableView.cellForModel) as? (UITableView, Any, IndexPath) -> UITableViewCell?
        }
        set {
            setProperty(for: &Keys.UITableView.cellForModel, newValue, policy: .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var registeredIdentifiers: [(AnyClass, String, AnyClass)] {
        get {
            guard let identifiers = property(for: &Keys.UITableView.registeredIdentifiers) as? [(AnyClass, String, AnyClass)] else {
                let identifiers = [(AnyClass, String, AnyClass)]()
                setProperty(for: &Keys.UITableView.registeredIdentifiers, identifiers)
                return identifiers
            }
            return identifiers
        }
        set {
            setProperty(for: &Keys.UITableView.registeredIdentifiers, newValue)
        }
    }
    
    final func classAndIdentifier(for model: Any) -> (AnyClass, String, AnyClass)? {
        guard let model = model as? NSObjectProtocol else {
            return nil
        }
        var matches = [(AnyClass, String, AnyClass)]()
        for (modelType, identifier, cellType) in registeredIdentifiers {
            if model.isKind(of: modelType) {
                matches.append((modelType, identifier, cellType))
            }
        }
        return matches.sorted { $0.0.isSubclass(of: $1.0) }.first
    }
    
    final func identifier(for model: Any) -> String? {
        if let identifier = identifierForModel?(model) {
            return identifier
        }
        return classAndIdentifier(for: model)?.1
    }
    
    final func cell(for model: Any, indexPath: IndexPath) -> UITableViewCell? {
        if let cell = cellForModel?(self, model, indexPath) {// 是否手动配置 cell
            return cell
        }
        if let model = model as? NSObjectProtocol {
            if let identifier = identifier(for: model) {// 是否是注册 cell
                return dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            }
        }
        return nil
    }
    
    final func register<T: UITableViewCell, O: NSObjectProtocol>(cell: T.Type, for model: O.Type) {
        registReusable(cell)
        if let model = model as? NSObject.Type {
            registeredIdentifiers += [(model.classForCoder(), cell.identifier, cell)]
        }
    }
}
