//
//  list_collection_context+.swift
//  quickswift
//
//  Created by suyikun on 2022/7/29.
//

import Foundation
import IGListKit

extension ListCollectionContext {
    
    // swiftlint:disable force_cast
    /// cls 是什么类型，返回就是什么类型
    func reusable<T: UICollectionViewCell>(_ cls: T.Type, for sectionController: ListSectionController, at index: Int) -> T {
        let name = String(describing: cls)
        let xibPath = Bundle.main.path(forResource: name, ofType: "nib")
        if let path = xibPath {
            let exists = FileManager.default.fileExists(atPath: path)
            
            if exists {
                let cell = self.dequeueReusableCell(withNibName: name, bundle: nil, for: sectionController, at: index) as! T
                
                cell.nextResponder = sectionController
                return cell
            }
        }
        let cell = self.dequeueReusableCell(of: cls, for: sectionController, at: index) as! T
        cell.nextResponder = sectionController
        return cell
    }
    // swiftlint:enable force_cast
}

extension ListSectionController {
    /// 这里没必要用 optional 的 collectionContext, 反正为空的时候取不到 cell 也是一样的要崩，we don't care
    var context: ListCollectionContext {
        return collectionContext.despair("the collection-context is nil.")
    }
}
