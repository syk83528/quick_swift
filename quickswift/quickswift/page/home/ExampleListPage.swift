//
//  ExampleListPage.swift
//  quickswift
//
//  Created by suyikun on 2022/7/28.
//

import Foundation
import IGListKit

class ExampleListController: UIViewController, TableProvider {
    
    typealias DataType = ExampleItemModel
    //MARK:- --------------------------------------infoProperty
    var items: [ExampleItemModel] =
    [
        ExampleItemModel(name: "Test", T: TestViewController.self),
        ExampleItemModel(name: "CollectTest", T: TestCollectPage.self),
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
    
    //MARK:- --------------------------------------UIProperty
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    //MARK:- --------------------------------------system
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewController.moveTo(self)
        tableView.register(cell: ExampleItemCell.self, for: ExampleItemModel.self)
        tableViewController.selectCell.observeValues {[weak self] model in
            guard self != nil else { return }
            (model.T as? UIViewController.Type)?.push()
        }
        list = items
        tableView.reloadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.pin.all()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    //MARK:- --------------------------------------actions
    //MARK:- --------------------------------------net
}

class ExampleItemModel: DataModel, LayoutCachable {
    
    var cellHeight: CGFloat = 44

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

class ExampleItemCell: TableViewCell {
    override func commonInit() {
        textLabel?.textColor = .title
        contentView.backgroundColor = .randomWithLight
    }
    override func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ExampleItemModel else { return }
        self.textLabel?.text = viewModel.name
    }
}

extension ExampleListController: TabProvider {
    var tabIdentifier: String {
        "example"
    }
    
    var tabTitle: String {
        "消息"
    }
    
    var tabImageName: String {
        "tab_message"
    }
    
    var controller: UIViewController {
        self
    }
    
}
