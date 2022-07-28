////
////  GradientButton.swift
////  spsd
////
////  Created by 未来 on 2019/12/10.
////  Copyright © 2019 Wildog. All rights reserved.
////
//
//import UIKit
//
//class GradientButton: UIView {
//    
//    var object: Any?
//    
//    var titleLabel: UILabel = UILabel()
//    
//    /// 初始化设置走这个
//    var startColor: UIColor = #colorLiteral(red: 0.6705882353, green: 0.3490196078, blue: 1, alpha: 1)
//    /// 初始化设置走这个
//    var endColor: UIColor = #colorLiteral(red: 1, green: 0.3019607843, blue: 0.5215686275, alpha: 1)
//    
//    /// 默认的gradientView 是2  越接近0 两边过度越平缓  >5之后过渡十分硬
//    var interpolationFactor: CGFloat = 0 {
//        didSet {
//            self.gradientView.interpolationFactor = interpolationFactor
//        }
//    }
//    
//    /// 中途设置走这个
//    var colors: [UIColor]? {
//        willSet {
//            if newValue != nil, newValue.count == 2 {
//                self.startColor = newValue?.first ?? startColor
//                self.endColor = newValue?.last ?? endColor
//                gradientView.colors = newValue
//            }
//        }
//    }
//    
//    private var defaultGradientColor: [UIColor] {
//        [self.startColor, self.endColor]
//    }
//    private var disableGradientColor: [UIColor] {
//        [self.startColor.saturation(0.45), self.endColor.saturation(0.45)]
//    }
//    private var highlightedGradientColor: [UIColor] {
//        [self.startColor.brightness(0.6), self.endColor.brightness(0.6)]
//    }
//    
//    private lazy var gradientView: GradientView = { [unowned self] in
//        let v = GradientView()
//        v.layer.masksToBounds = true
//        v.colors = self.defaultGradientColor
//        v.position = .horizontal
//        v.isUserInteractionEnabled = false
//        return v
//    }()
//    
//    var fontSize: CGFloat = 16 {
//        didSet {
//            titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
//        }
//    }
//    
//    var backgroundColor: UIColor? {
//        didSet {
//            if backgroundColor != nil {
//                gradientView.snp.removeConstraints()
//                gradientView.removeFromSuperview()
//            } else {
//                insertSubview(self.gradientView, at: 0)
//                gradientView.snp.makeConstraints { (maker) in
//                    maker.edges.equalTo(self)
//                }
//            }
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        commonInit()
//    }
//    
//    /// colors.count == 2, first: StartColor, last: EndColor
//    convenience init(colors: UIColor...) {
//        self.init(type: .custom)
//        if colors.count != 2 {
//            return
//        }
//        self.startColor = colors.first!
//        self.endColor = colors.last!
//    }
//    
//    override func setImage(_ image: UIImage?, for state: UIControl.State) {
//        super.setImage(image, for: state)
//        if let imgv = imageView {
//            self.bringSubviewToFront(imgv)
//        }
//    }
//    
//    override var isEnabled: Bool {
//        didSet {
//            if !isEnabled {
//                self.gradientView.colors = disableGradientColor
//            } else {
//                self.gradientView.colors = defaultGradientColor
//            }
//        }
//    }
//    override var isHighlighted: Bool {
//        didSet {
//            if isHighlighted {
//                self.gradientView.colors = highlightedGradientColor
//            } else {
//                self.gradientView.colors = defaultGradientColor
//            }
//        }
//    }
//    
//    private func commonInit() {
//        circle = true
//        setTitleColor(.white, for: .normal)
//        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
//    }
//    
//    override func willMove(toSuperview newSuperview: UIView?) {
//        super.willMove(toSuperview: newSuperview)
//        // add gradient view
//        
//        if backgroundColor == nil {
//            insertSubview(self.gradientView, at: 0)
//            self.gradientView.snp.makeConstraints { (maker) in
//                maker.edges.equalTo(self)
//            }
//        }
//    }
//}
