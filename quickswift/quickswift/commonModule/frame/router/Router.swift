//
//  Router.swift
//  quick
//
//  Created by suyikun on 2021/6/23.
//

import Foundation
import common
import RTNavigationController

struct Router {
    private init() { }
}


extension String {
    
    var hasHttpScheme: Bool {
        hasPrefix("http://", "https://")
    }
    
    var hasNativeScheme: Bool {
        hasPrefix("native://")
    }
    
    var hasRouterScheme: Bool {
        hasPrefix("duomi://")
    }
    
    var hasMediatorScheme: Bool {
        hasPrefix("mediator://")
    }
    
}

extension Keys {
    struct Router {
        static var moduleParamKey = "Router.moduleParamKey"
        static var pathParamKey = "Router.pathParamKey"
    }
}


extension UIViewController {
    static func push(animated: Bool = true) {
        Router.push(self, animated: animated)
    }
    
    func push(animated: Bool = true) {
        Router.push(self, animated: animated)
    }
    
    static func present(animated: Bool = true) {
        var vc: UIViewController?
        if let sb = (self as? StoryboardCompatible.Type) {
            vc = sb.fromStoryboard() as? UIViewController
        } else {
            vc = self.init()
        }
        if let vc = vc {
            UIViewController.current?.present(vc, animated: animated)
        }
    }
    
    func present(animated: Bool = true) {
        UIViewController.current?.present(self, animated: animated)
    }
}

extension Router {
    fileprivate static func push<T: UIViewController>(_ viewController: T.Type, animated: Bool = true) {
        var vc: T?
        if let sb = (viewController as? StoryboardCompatible.Type) {
            vc = (sb.fromStoryboard() as! T)
        } else {
            vc = viewController.init()
        }
        if let vc = vc {
            push(vc, animated: animated)
        }
    }
    
    fileprivate static func push(_ viewController: UIViewController, animated: Bool = true) {
        
        defer {
            //            LiveManager.shared.minimizeWindowIfNeeded()
            //            CallManager.shared.minimizeWindowIfNeeded()
            
            // TODO: backToLive
            //            viewController.processBackWindow(param: params)
        }
        
        //        viewController.process(params: params)
        
        guard let nav = UINavigationController.pusher else {
            let wrapper = RTRootNavigationController.init(rootViewController: viewController)
            UIViewController.current?.present(wrapper, animated: animated, completion: nil)
            return
        }
        
        doPush(viewController, nav: nav, animated: animated)
        
    }
    
    private static func doPush(_ viewController: UIViewController, nav: UINavigationController, animated: Bool) {
        guard let intent = viewController.intent as? Intent else {
            nav.pushViewController(viewController, animated: animated)
            return
        }
        switch intent {
        case let .popToExisted(intents):
            doPopToExisted(viewController,
                           nav: nav,
                           intents: intents,
                           animated: animated)
        case let .pushReplace(intents):
            doPushReplace(viewController,
                          nav: nav,
                          intents: intents,
                          animated: animated)
        case let .pushExisted(intents):
            doPushExisted(viewController,
                          nav: nav,
                          intents: intents,
                          animated: animated)
        }
    }
    
    private static func doPopToExisted(_ viewController: UIViewController, nav: UINavigationController, intents: [String]? = nil, animated: Bool) {
        var popTo: UIViewController?
        for vc in nav.viewControllers {
            if let containerVC = vc as? RTContainerController,
               let contentVC = containerVC.contentViewController,
               contentVC.classForCoder == viewController.classForCoder,
               contentVC.intentValue(for: intents).equalTo(viewController.intentValue(for: intents)) {
                popTo = contentVC
                break
            } else if vc.classForCoder == viewController.classForCoder,
                      vc.intentValue(for: intents).equalTo(viewController.intentValue(for: intents)) {
                popTo = vc
                break
            }
        }
        if let popTo = popTo {
            nav.popToViewController(popTo, animated: animated)
        } else {
            nav.pushViewController(viewController, animated: animated)
        }
    }
    
    private static func doPushReplace(_ viewController: UIViewController, nav: UINavigationController, intents: [String]? = nil, animated: Bool) {
        var existed: UIViewController?
        for vc in nav.viewControllers {
            if let containerVC = vc as? RTContainerController,
               let contentVC = containerVC.contentViewController,
               contentVC.classForCoder == viewController.classForCoder,
               contentVC.intentValue(for: intents).equalTo(viewController.intentValue(for: intents)) {
                existed = contentVC
                break
            } else if vc.classForCoder == viewController.classForCoder,
                      vc.intentValue(for: intents).equalTo(viewController.intentValue(for: intents)) {
                existed = vc
                break
            }
        }
        if let existed = existed {
            if let nav = nav as? RTRootNavigationController {
                nav.removeViewController(existed, animated: false)
            } else {
                nav.setViewControllers(nav.viewControllers.filter { $0 != existed }, animated: false)
            }
        }
        nav.pushViewController(viewController, animated: true)
    }
    
    private static func doPushExisted(_ viewController: UIViewController, nav: UINavigationController, intents: [String]? = nil, animated: Bool) {
        var existed: UIViewController?
        for vc in nav.viewControllers {// 遍历栈控制器
            if let containerVC = vc as? RTContainerController,
               let contentVC = containerVC.contentViewController,// RT 包装的话就取contentViewController
               contentVC.classForCoder == viewController.classForCoder,
               contentVC.intentValue(for: intents).equalTo(viewController.intentValue(for: intents)) {// 核心判断代码
                existed = contentVC
                break
            } else if vc.classForCoder == viewController.classForCoder,
                      vc.intentValue(for: intents).equalTo(viewController.intentValue(for: intents)) {
                existed = vc
                break
            }
        }
        if let existed = existed {
            if let nav = nav as? RTRootNavigationController {
                if nav.rt_visibleViewController == existed {//如果在栈顶则不操作
                    return
                }
                nav.removeViewController(existed, animated: false)
            } else {
                nav.setViewControllers(nav.viewControllers.filter { $0 != existed }, animated: false)
            }
        }
        if let existed = existed {
            nav.pushViewController(existed, animated: true)
        } else {
            nav.pushViewController(viewController, animated: true)
        }
    }
    
}

extension Router {
    static func dismiss(_ viewController: UIViewController? = UIViewController.current) {
        UIViewController().rt_navigationBarClass()
        viewController?.dismiss()
    }
    
    // to 为空时一直删到栈顶
    static func dismiss(from: (UIViewController) -> Bool, to: ((UIViewController) -> Bool)? = nil, animated: Bool = true) {
        guard let nav = UINavigationController.pusher else {
            return
        }
        
        var fromVC: UIViewController?
        var toVC: UIViewController?
        
        let controllers = nav.viewControllers
        
        for vc in controllers {
            if let containerVC = vc as? RTContainerController,
               let contentVC = containerVC.contentViewController {
                if from(contentVC) {
                    fromVC = containerVC
                    break
                }
            } else if from(vc) {
                fromVC = vc
                break
            }
        }
        
        guard let fromViewController = fromVC else {
            return
        }
        
        if let to = to {
            for vc in controllers.split(separator: fromViewController).last ?? [] {
                if let containerVC = vc as? RTContainerController,
                   let contentVC = containerVC.contentViewController {
                    if to(contentVC) {
                        toVC = containerVC
                        break
                    }
                } else if to(vc) {
                    toVC = vc
                    break
                }
            }
        } else {
            let lastVC = controllers.last
            if let container = lastVC as? RTContainerController {
                toVC = container.contentViewController
            } else {
                toVC = lastVC
            }
        }
        
        guard let toViewController = toVC else {
            return
        }
        
        var heads = (controllers.split(separator: fromViewController).first ?? [])
        var tails = ArraySlice<UIViewController>()
        let splitted = controllers.split(separator: toViewController)
        if splitted.count > 1, let last = splitted.last {
            tails = last
        }
        if heads.count == controllers.count {
            heads = []
        }
        if tails.count == controllers.count {
            tails = []
        }
        
        let finalViewControllers = heads + tails
        nav.setViewControllers([UIViewController](finalViewControllers), animated: animated)
    }
    
    static func remove(controller: UIViewController, delay: TimeInterval = 0.5, animated: Bool = false) {
        if delay > 0 {
            Common.Delay.execution(delay: delay) {
                doRemove(controller: controller, animated: animated)
            }
        } else {
            doRemove(controller: controller, animated: animated)
        }
    }
    
    private static func doRemove(controller: UIViewController, animated: Bool = false) {
        guard let nav = UINavigationController.pusher else {
            return
        }
        
        let controllers = nav.viewControllers.filter { (vc) -> Bool in
            if let containerVC = vc as? RTContainerController {
                return containerVC.contentViewController != controller
            }
            return vc != controller
        }
        nav.setViewControllers(controllers, animated: animated)
    }
    
    /// 移除控制器，通常用于 push 后，移除中间层
    /// - Parameters:
    ///   - controllerNames: 控制器名称，传字符串
    ///   - skip: 有多个同名控制器存在时，找到第一个之后(倒找)就跳过
    ///   - skipFirst: 有多个同名控制器存在时，跳过栈顶的第一个找到的控制器
    ///   - animated: 是否有动画显示，默认为 false
    static func removeControllers(names controllerNames: [String], skip: Bool = false, skipFirst: Bool = false, animated: Bool = false) {
        guard let nav = UINavigationController.pusher else {
            log("[Router.swift, removeControllers]: Can't find navigation controller")
            return
        }
        
        var willRemovingControllers: [UIViewController] = []
        var willRemovingControllerNames: [String] = []
        var firstSkipRemovingControllNames: [String] = []
        
        var controllers = nav.viewControllers
        for vc in controllers.reversed() {
            if let containerVC = vc as? RTContainerController, let contentVC = containerVC.contentViewController {
                let contentVCClassName = contentVC.clazzName.replace(Const.project, to: "")
                if controllerNames.contains(contentVCClassName) {
                    if skipFirst, !firstSkipRemovingControllNames.contains(contentVCClassName) {
                        firstSkipRemovingControllNames.append(contentVCClassName)
                        continue
                    }
                    if skip, willRemovingControllerNames.contains(contentVCClassName) {
                        continue
                    }
                    willRemovingControllers.append(vc)
                    willRemovingControllerNames.append(contentVCClassName)
                }
            }
        }
        guard willRemovingControllers.count > 0 else { return }
        
        for willRemoving in willRemovingControllers {
            controllers.removeFirst(object: willRemoving)
        }
        nav.setViewControllers(controllers, animated: animated)
    }
    
    /// 移除控制器，用于不知道后面弹出的控制器类型，反正一直移除到当前控制器
    /// - Parameters:
    ///   - controler: 当前控制器
    ///   - dismissUtil: 当前控制器是否需要移除，默认为 true
    ///   - aniamted: 动画，默认 false
    static func dismissUtil(controler: UIViewController? = UIViewController.current, dismissUtil: Bool = true, aniamted: Bool = false) {
        // TODO:
    }
}

extension UINavigationController {
    public static var pusher: UINavigationController? {
        guard let targetWindow = AppDelegate.shared.window, let r = targetWindow.rootViewController else {
            return nil
        }
        
        var root: UIViewController? = r
        while root!.presentedViewController != nil {
            root = root!.presentedViewController
        }
        
        if let nav = root! as? RTRootNavigationController {
            return nav
        } else if let nav = root! as? UINavigationController {
            return nav
        }
        return nil
    }
}

extension Router {
    /// 打开系统设置
    static func openSettings() {
        let settingsURL = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
}
