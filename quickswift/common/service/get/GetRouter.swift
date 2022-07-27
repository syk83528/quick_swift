////
////  GetRouter.swift
////  spsd
////
////  Created by suyikun on 2022/1/7.
////  Copyright © 2022 未来. All rights reserved.
////
//
//import Foundation
//
//class GetRouter {
//    // MARK: - --------------------------------------singleton
//    private static let to = GetRouter()
//    private init() {}
//    // MARK: - --------------------------------------property
//    /// 路由处理
//    private var handler: GetRouterHandlerDelegate?
//    // MARK: - --------------------------------------func
//
//    ///  注册路由处理
//    static func registerHandler(_ handler: GetRouterHandlerDelegate) {
//        to.handler = handler
//    }
//
//    /// 路由方法
//    static func router(name: String?, arguments: Dict?) {
//        guard var name = name else { return }
//
//        name = to._urlEncoding(name)
//
//        if let urlComponents = URLComponents(string: name) {
//            // url 路由,包括协议 native, http, https 比如 native://www.taoqu.com?ios_path=/mine/setting&userId=200944533
//            to._parse(urlComponents: urlComponents, argument: arguments)
//        } else {
//            // 本地路由, 比如 name=/mine/setting
//            to.handler?.handler(path: name, arguments: arguments)
//        }
//    }
//    
//    private func _urlEncoding(_ url: String) -> String {
////        CharacterSet.urlHostAllowed: 被转义的字符有  "#%/<>?@\^`{|}
////        CharacterSet.urlPathAllowed: 被转义的字符有  "#%;<>?[\]^`{|}
////        CharacterSet.urlUserAllowed: 被转义的字符有   "#%/:<>?@[\]^`
////        CharacterSet.urlQueryAllowed: 被转义的字符有  "#%<>[\]^`{|}
////        CharacterSet.urlPasswordAllowed 被转义的字符有 "#%/:<>?@[\]^`{|}
////        CharacterSet.urlFragmentAllowed 被转义的字符有 "#%<>[\]^`{|}
////        let characterSet = CharacterSet(charactersIn: "#").inverted
//        getllog(url)
//        let characterSet = CharacterSet.urlQueryAllowed
//        let encodingUrl = url.addingPercentEncoding(withAllowedCharacters: characterSet) ?? url
//        getllog(encodingUrl)
//        return encodingUrl
//    }
//
//    /// 路由解析, 将远程或者本地的路由整合到一个 Map 中
//    /// - Parameters:
//    ///   - name: 全路由
//    ///   - argument: 参数
//    private func _parse(urlComponents: URLComponents, argument: Dict?) {
//        // 拼接参数,合并参数
//        var dict = argument ?? Dict()
//        if let queryItems = urlComponents.queryItems {
//            for queryItem in queryItems {
//                if let value = queryItem.value {
//                    log("key: \(queryItem.name), value: \(value)")
//                    dict[queryItem.name] = value
//                }
//            }
//        }
//        /// 执行路由
//        _doRouter(urlComponents: urlComponents, argument: dict)
//    }
//
//    private func _doRouter(urlComponents: URLComponents, argument: Dict?) {
//        guard let scheme = urlComponents.scheme else {
//            return
//        }
//        switch scheme {
//        case GetRouterConfig.native.scheme:
//            guard let ios_path = argument?["ios_path"] as? String else { return }
//            handler?.handler(path: ios_path, arguments: argument)
//        case GetRouterConfig.http.scheme, GetRouterConfig.https.scheme:
//            handler?.handler(path: "http", arguments: argument)
//        default:
//            getllog("协议头错误")
//        }
//    }
//}
//
//
//struct RougerHandler: GetRouterHandlerDelegate {
//    let subHandlers: [GetRouterHandlerDelegate] = [
//        RouterGeneralHandler(),
//        RouterPersonHandler(),
//    ]
//
//    func handler(path: String, arguments: Dict?) -> Bool {
//        for handler in subHandlers {
//            if handler.handler(path: path, arguments: arguments) {
//                return true
//            } else {
//                continue
//            }
//        }
//        getllog("路由无法被解析")
//        return false
//    }
//}
//
//
///// 公共路由
//struct RouterGeneralHandler: GetRouterHandlerDelegate {
//    func handler(path: String, arguments: Dict?) -> Bool {
//        switch path {
//        case GetRouterName.http.rawValue:
//            getllog("处理了")
//        default:
//            return false
//        }
//        return true
//    }
//}
//
///// 社区路由
//struct RouterCommunityHandler: GetRouterHandlerDelegate {
//    func handler(path: String, arguments: Dict?) -> Bool {
//        switch path {
//        case GetRouterName.community_post_detail.rawValue:
//            getllog("跳转community_post_detail")
//            if let postId = arguments?["postId"] as? String {
//                PostDetailController(postId: postId).push()
//            }
//        default:
//            return false
//        }
//        return true
//    }
//}
//
///// 个人模块路由
//struct RouterPersonHandler: GetRouterHandlerDelegate {
//    func handler(path: String, arguments: Dict?) -> Bool {
//        switch path {
//        case GetRouterName.mine_setting.rawValue:
//            getllog("跳转个人设置")
//            SettingVC.push()
//        case GetRouterName.mine_complete.rawValue:
//            getllog("跳转完善资料")
//            CompleteInfoVC.push()
//        default:
//            return false
//        }
//        return true
//    }
//}
