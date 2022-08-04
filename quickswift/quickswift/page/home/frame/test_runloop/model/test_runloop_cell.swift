//
//  test_runloop_cell.swift
//  quickswift
//
//  Created by suyikun on 2022/8/1.
//

import Foundation
import common

class TestRunloopCell: TableViewCell {
    override func commonInit() {
        textLabel?.textColor = .title
        contentView.backgroundColor = .randomWithLight
    }
    override func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? TestRunloopModel else { return }
        self.textLabel?.text = viewModel.name
    }
}
