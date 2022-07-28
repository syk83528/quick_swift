//  Created by iWe on 2017/9/6.
//  Copyright © 2017年 iWe. All rights reserved.
//

#if os(iOS)
import UIKit

extension UICollectionReusableView: IWNibReusable { }

public extension UICollectionView {
    
    // MARK: Regist reusable cell
    /// Regist reusable cell.
    /// (注册复用Cell). 优先从 xib 获取
    final func registReusable<T: UICollectionViewCell>(_ cellType: T.Type) {
        let name = String(describing: cellType)
        let xibPath = Bundle.main.path(forResource: name, ofType: "nib")
        if let path = xibPath {
            let exists = FileManager.default.fileExists(atPath: path)
            if exists {
                register(cellType.nib, forCellWithReuseIdentifier: cellType.identifier)
                return
            }
        }
        register(cellType.self, forCellWithReuseIdentifier: cellType.identifier)
    }
    
    /// (从复用池取出Cell).
    final func reuseCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cellType.identifier)")
        }
        return cell
    }
}

public extension UICollectionView {
    
    /// (注册可复用View).
    final func registReusableView<T: UICollectionReusableView>(supplementaryViewType: T.Type = T.self, ofKind elementKind: String) {
        self.register(supplementaryViewType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: supplementaryViewType.identifier)
    }
    
    /// (从复用池取出View).
    final func reuseReusableView<T: UICollectionReusableView>(ofKind elementKind: String, for indexPath: IndexPath, viewType: T.Type = T.self) -> T {
        let view = self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: viewType.identifier, for: indexPath)
        guard let typedView = view as? T else {
            fatalError(
                "Failed to dequeue a supplementary view with identifier \(viewType.identifier) matching type \(viewType.self). "
            )
        }
        return typedView
    }
}

#endif
