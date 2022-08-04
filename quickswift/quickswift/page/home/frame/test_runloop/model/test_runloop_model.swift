//
//  test_runloop_model.swift
//  quickswift
//
//  Created by suyikun on 2022/8/1.
//

import Foundation
import IGListDiffKit

class TestRunloopModel: DataModel, LayoutCachable {
    var cellHeight: CGFloat = 44

    var name: String
    
    init(name: String) {
        self.name = name
        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        "\(name)" as NSObjectProtocol
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let model = object as? Self else { return false }
        return name == model.name
    }
}
