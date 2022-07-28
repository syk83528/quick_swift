//  Created by iWe on 2017/9/6.
//  Copyright © 2017年 iWe. All rights reserved.
//

#if os(iOS)
import UIKit

extension UITableViewCell: IWNibReusable { }
extension UITableViewHeaderFooterView: IWNibReusable { }

// MARK: - Cell
public extension UITableView {

    // MARK: Regist reusable cell
    /// (regist Cell).
    final func registReusable<T: UITableViewCell>(_ cell: T.Type) {
        let name = String(describing: cell)
        let xibPath = Bundle.main.path(forResource: name, ofType: "nib")
        if let path = xibPath {
            let exists = FileManager.default.fileExists(atPath: path)
            if exists {
                register(cell.nib, forCellReuseIdentifier: cell.identifier)
            }
        } else {
            register(cell.self, forCellReuseIdentifier: cell.identifier)
        }
    }
    
    final func registReusable<T: UITableViewCell>(_ cells: [T.Type]) {
        for cell in cells {
            registReusable(cell)
        }
    }
    
    /// (dequeue reusable Cell).
    final func reuseCell<T: UITableViewCell>(_ cellType: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.identifier ) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cellType.identifier)")
        }
        return cell
    }
    /// (dequeue reusable Cell).
    final func reuseCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cellType.identifier)")
        }
        return cell
    }
    /// (dequeue reusable Cell).
    final func autoReuseCell<T: UITableViewCell>(_ cellType: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.identifier ) as? T else {
            register(cellType, forCellReuseIdentifier: cellType.identifier)
            return reuseCell(cellType)
        }
        return cell
    }
}

// MARK: - Header footer view
public extension UITableView {

    // MARK: Regist reusable header footer
    /// (注册复用View).
    final func registReusable<T: UITableViewHeaderFooterView>(_ headerFooterView: T.Type = T.self) {
        let name = String(describing: headerFooterView)
        let xibPath = Bundle.main.path(forResource: name, ofType: "nib")
        if let path = xibPath {
            let exists = FileManager.default.fileExists(atPath: path)
            if exists {
                register(headerFooterView.nib, forHeaderFooterViewReuseIdentifier: headerFooterView.identifier)
            }
        } else {
            register(headerFooterView.self, forHeaderFooterViewReuseIdentifier: headerFooterView.identifier)
        }
    }
    /// (从复用池取出View).
    final func reuseHeaderFooter<T: UITableViewHeaderFooterView>(_ type: T.Type = T.self) -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: type.identifier) as? T else {
            fatalError("Failed to dequeue a header footer view with identifier \(type.identifier)")
        }
        return view
    }
}

#endif
