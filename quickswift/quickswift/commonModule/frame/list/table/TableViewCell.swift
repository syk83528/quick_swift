//
//  TableViewCell.swift
//  quick
//
//  Created by suyikun on 2021/6/27.
//

import Foundation
import IGListKit
import FlexLayout

class TableViewCell: UITableViewCell, ListBindable {
    private var flexInit = false
    lazy var containerView: UIView = {
        flexInit = true
        let v = UIView()
//        v.isSkeletonPlaceholder = true
        v.add(to: contentView)
        
        return v
    }()
    var rootFlex: Flex {
        containerView.flex
    }
    var layoutMode: Flex.LayoutMode {
        .fitContainer
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        __commonInit()
        allEvents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        __commonInit()
        allEvents()
    }
    
    private func __commonInit() {
        selectionStyle = .none
        backgroundColor = .clear
        
        commonInit()
    }
    
    func commonInit() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if flexInit {
            containerView.pin.all()
            containerView.flex.layout(mode: layoutMode)
        }
    }

    func bindViewModel(_ viewModel: Any) {
        
    }
    
    // MARK: - Responder事件处理
    func allEvents() {
       
    }
}
