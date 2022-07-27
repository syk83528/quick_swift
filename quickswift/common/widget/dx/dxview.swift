//
//  dxview.swift
//  common
//
//  Created by suyikun on 2022/7/27.
//

import Foundation
import FlexLayout
import PinLayout

class DXView: UIView {
    
    var flexLayoutMode: Flex.LayoutMode {
        .fitContainer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        allEvents()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
        allEvents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
        allEvents()
    }
    
    private var flexInited = false
    lazy var flexContainer: UIView = {
        self.flexInited = true
        return UIView().add(to: self)
    }()
    var rootFlex: Flex {
        flexContainer.flex
    }
    
    func commonInit() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if flexInited {
            flexContainer.pin.all()
            flexContainer.flex.layout(mode: flexLayoutMode)
        }
    }
    
    func allEvents() {
        
    }
}

class DXViewWithoutFlex: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        
    }
}
