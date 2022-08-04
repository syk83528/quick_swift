//
//  test_collect_page.swift
//  quickswift
//
//  Created by suyikun on 2022/7/28.
//

import Foundation
import IGListKit
import FlexLayout
import PinLayout
import common

class TestCollectPage: BasePage, CollectionProvider {
    
    typealias DataType = TestCollectItemModel
    
    var items: [TestCollectItemModel] =
    [
        TestCollectItemModel(name: "Test", T: TestViewController.self),
        TestCollectItemModel(name: "asdasdad", T: TestViewController.self),
        TestCollectItemModel(name: "安师大收到", T: TestViewController.self),
        TestCollectItemModel(name: "请问请问去", T: TestViewController.self),
        TestCollectItemModel(name: "同仁堂如果", T: TestViewController.self),
        TestCollectItemModel(name: "哼哼唧唧黑胡椒", T: TestViewController.self),
        TestCollectItemModel(name: "大S打撒第三大", T: TestViewController.self),
//        ExampleItemModel(name: "盒子模型", T: BoxViewController.self),
//        ExampleItemModel(name: "流水布局", T: FirstBigViewController.self),
//        ExampleItemModel(name: "导航转场动画", T: NavAnimateController.self),
//        ExampleItemModel(name: "视频捕获", T:  CaptureVideoPage.self),
//        ExampleItemModel(name: "音视频大小窗", T:  CallCameraSwitchController.self),
//        ExampleItemModel(name: "TAG标签界面", T: TagModelViewController.self),
//        ExampleItemModel(name: "测试", T: TestViewController.self),
//        ExampleItemModel(name: "TextureDemo测试", T: TestTextureViewController.self),
//        ExampleItemModel(name: "裸眼3D", T: CoreMotionViewController.self),
        
    ]
    
    var scrollDirection: UICollectionView.ScrollDirection {
        .vertical
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "测试IGListKit"
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionViewController.moveTo(self)
//        collectionView.register(controller: ListSingleSectionController<TestCollectItemModel, TestCollectItemCell>.self, for: TestCollectItemModel.self)
        collectionView.sectionControllerForModel = { m in
            switch m {
            case is TestCollectItemModel:
//                let c = TestCollectSectionController()
//                c.inset = .init(top: 10, left: 10, bottom: 10, right: 10)
//                return c
                return TestCollectSectionController()
            default:
                return ListSectionController()
            }
        }
        collectionViewController.selectCell.observeValues {[weak self] model in
            guard self != nil else { return }
            (model.T as? UIViewController.Type)?.push()
        }
        list = items
        forceReloadData()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.pin.all()
    }
}

class TestCollectSectionController: ListSingleSectionController<TestCollectItemModel, TestCollectItemCell>  {
    
}

class TestCollectItemModel: DataModel, LayoutCachable {
    
    var cellSize: CGSize {
        MakeSize(150, 150)
    }

    var name: String
    
    var T: AnyClass
    
    init(name: String, T: AnyClass) {
        self.name = name
        self.T = T
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

class TestCollectItemCell: CollectionViewCell {
    override func commonInit() {
        super.commonInit()
        
        contentView.backgroundColor = .random
    }
    override func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? TestCollectItemModel else { return }
//        self.textLabel?.text = viewModel.name
    }
}
