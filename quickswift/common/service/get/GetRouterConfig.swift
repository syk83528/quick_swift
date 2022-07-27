import Foundation
////
////  GetRouterConfig.swift
////  spsd
////
////  Created by suyikun on 2022/1/7.
////  Copyright © 2022 未来. All rights reserved.
////
//
//import Foundation
//
protocol GetRouterHandlerDelegate {
    
    /// 处理路由跳转
    /// - Returns: true 成功处理路由 false 处理路由失败
    @discardableResult
    func handler(path: String, arguments: Dict?) -> Bool
}
//
struct GetRouterConfig: Equatable {
    static let native = GetRouterConfig(scheme: "native")
    static let http = GetRouterConfig(scheme: "http")
    static let https = GetRouterConfig(scheme: "https")
    /// 原生跳转协议头
    var scheme: String
    var path: String = ""
    var port: String = ""
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.scheme == rhs.scheme
    }
}

enum GetRouterName: String {
    // MARK: - --------------------------------------公共
    case http = "http"
    case https = "https"
    // MARK: - --------------------------------------发现
    
    // MARK: - --------------------------------------社区
    case community_post_detail = "community_post_detail"
    // MARK: - --------------------------------------个人
    
    // MARK: - --------------------------------------我的
    case mine_setting = "mine_setting"
    case mine_complete = "mine_complete"
    // MARK: - --------------------------------------帖子
    case post_detail = "post_detail"
}
