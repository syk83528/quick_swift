//
//  datamodel.swift
//  quickswift
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import HandyJSON
import IGListDiffKit

class DataModel: NSObject, HandyJSON, ListDiffable {
    required override init() { }
    
    func diffIdentifier() -> NSObjectProtocol { (toJSONString() ?? "") as NSObjectProtocol }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool { self === object }

    func mapping(mapper: HelpingMapper) { }

    func didFinishMapping() { }
}
