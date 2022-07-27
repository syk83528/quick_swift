//
//  OperationUtil.swift
//  spsd
//
//  Created by suyikun on 2022/7/20.
//  Copyright © 2022 未来. All rights reserved.
//

import Foundation
import ReactiveSwift

/// 操作的工具类  没有使用map,lastTimeInterval和debounce都是共用的,希望使用的人用在UI操作上
public class OperationUtil {
    private static var lastTimeInterval: TimeInterval = 0
    private static var debounceTimer: Disposable?
    /// 防抖 假设函数持续多次执行，我们希望让它冷静下来再执行。也就是当持续触发事件的时候，函数是完全不执行的，等最后一次触发结束的一段时间之后，再去执行。
    /// 比如 搜索页面,用户连续输入,等停下来再去触发搜索接口
    /// - Parameters:
    ///   - delay: 间隔索九
    ///   - callBack: 执行函数
    public static func debounce(delay: Double = 2, scheduler: QueueScheduler = QueueScheduler.main, callBack: @escaping (() -> ())) {
        debounceTimer?.dispose()
        debounceTimer = scheduler.schedule(after: delay, action: {
            callBack()
            debounceTimer = nil
        })
    }
    
    /// 节流 让函数有节制地执行，而不是毫无节制的触发一次就执行一次。什么叫有节制呢？就是在一段时间内，只执行一次。
    /// 比如 防止按钮连点
    /// - Parameters:
    ///   - delay: 间隔索九
    ///   - callBack: 执行函数
    public static func throttle(delay: Double = 2, callBack: (() -> ())) {
        let now = Date().timeIntervalSince1970
        if now - lastTimeInterval > delay {
            callBack()
            lastTimeInterval = Date().timeIntervalSince1970
        } else {
            print("拦截了~~~~")
        }
    }
}
