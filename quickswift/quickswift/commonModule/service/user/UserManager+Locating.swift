//
//  UserManager+Locating.swift
//  spsd
//
//  Created by iWw on 2020/6/3.
//  Copyright © 2020 未来. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import CoreLocation
import SwiftLocation

extension UserManager {
    
    /// Bool 表示是否授权获取地理位置信息， (String?, String?)? 是 longitude, latitude，为 nil 表示未获取到
    typealias LocationSignalProducer = SignalProducer<(Bool, (String?, String?)?), Never>
    
    /// 监听授权变更, 此信号不会自动停止, 需要监听者自己处理
    static func onAuthorizationChangeSignalProducer() -> SignalProducer<LocationManager.State, Never> {
        llog("LocationManager.Change.code")
        return .init { observer, lifetime in
            llog("LocationManager.Change.init")
            let onChangeId = LocationManager.shared.onAuthorizationChange.add { x in
                llog("LocationManager.Change.state:\(x)")
                observer.send(value: x)
            }
            lifetime.observeEnded {
                llog("LocationManager.Change.observeEnded")
                LocationManager.shared.onAuthorizationChange.remove(onChangeId)
            }
        }
    }
    
    /// 等待定位授权结果
    private func locationAuthorizationChange() -> SignalProducer<LocationManager.State, Never> {
        if LocationManager.state == .undetermined {
            LocationManager.shared.requireUserAuthorization()
        }
        // 是否需要跳过init值，（即第一次订阅时.初始值）
        return UserManager.onAuthorizationChangeSignalProducer().on(value: { x in
            if x == .undetermined {
                LocationManager.shared.requireUserAuthorization()
            }
        }).filter({ $0 != .undetermined })
    }
    
    /// 更新（获取）定位信息，更新后可直接从 UserManager.current 中获取
    /// - Returns: Bool 表示是否授权获取地理位置信息， (String?, String?)? 是 longitude, latitude，为 nil 表示未获取到
    func locating() -> LocationSignalProducer {
        guard UserManager.current != nil else {
            return .init(value: (false, nil))
        }
        
        return .empty
//        func updateUserLocation(_ coordinate: CLLocationCoordinate2D, place: Place) -> (String, String) {
//            // TODO: Apple 采用的高德数据, 是否还需要转换
//            let realCoordinate = coordinate.amapCoordinate
//            let lon = realCoordinate.longitude.retain(6)
//            let lat = realCoordinate.latitude.retain(6)
//            UserManager.current?.update(location: place, ll: (lon, lat))
//            DispatchQueue.global(qos: .userInitiated).async {
//                UserManager.current?.save()
//                UserUpdateAPI.shared.make(.updateLocation, behaviors: [.suppressMessage()]).start()
//            }
//            return (lon, lat)
//        }
//
//        // 取坐标
//        func getCoordinateSignal() -> SignalProducer<CLLocation?, Never> {
//            .init { (observer, lifetime) in
//                var isEnd = false // 仅做
//                let request = LocationManager.shared.locateFromGPS(.oneShot, accuracy: .city) { data in
//                    guard !isEnd else { return }
//                    var loc: CLLocation?
//                    switch data {
//                    case let .failure(error):
//                        llog("locateFromGPS.failed.\(error)")
//                        switch error {
//                        case .requiredLocationNotFound, .invalidAuthStatus:
//                            DispatchQueue.global(qos: .userInitiated).async {
//                                UserManager.current?.location = nil
//                                UserManager.current?.save()
//                            }
//                        default: break
//                        }
//                    case let .success(location):
//                        loc = location
//                    }
//                    observer.send(value: loc)
//                    observer.sendCompleted()
//                }
//                lifetime.observeEnded {
//                    isEnd = true
//                    request.stop()
//                }
//            }
//        }
//
//        // 转坐标
//        func convertCoordinateSignal(_ location: CLLocation) -> SignalProducer<Place?, Never> {
//            let option = GeocoderRequest.Options()
//            if !location.coordinate.isOutOfChina {
//                option.locale = "zh_CN"
//            }
//            return .init { observer, lifetime in
//                var isEnd = false
//                let request = LocationManager.shared.locateFromCoordinates(location.coordinate, service: .apple(option)) { data in
//                    guard !isEnd else { return }
//                    var place: Place?
//                    switch data {
//                    case let .failure(reason):
//                        logError("locateCoordinate.failed: \(reason.code), desc: \(reason.localizedDescription)")
//                    case let .success(places):
//                        place = places.first
//                    }
//                    observer.send(value: place)
//                    observer.sendCompleted()
//                }
//                lifetime.observeEnded {
//                    isEnd = true
//                    request.stop()
//                }
//            }
//        }
//
//        let gpsSignal: LocationSignalProducer = getCoordinateSignal()
//            .flatMap(.concat) { loc in
//                guard let location = loc else {
//                    return .init(value: (false, nil))
//                }
//                return convertCoordinateSignal(location).map({ place in
//                    var ll: (String, String)?
//                    if let place = place {
//                        ll = updateUserLocation(location.coordinate, place: place)
//                    }
//                    return (true, ll)
//                })
//            }
//        llog("LocationManager.state:\(LocationManager.state)")
//        // 根据当前定位状态 判断
//        switch LocationManager.state {
//        case .denied, .restricted, .disabled:
//            return .init(value: (false, nil))
//        case .available:
//            return gpsSignal
//        case .undetermined:
//            return locationAuthorizationChange().take(first: 1)
//                .observe(on: QueueScheduler())
//                .flatMap(.concat, { state -> LocationSignalProducer in
//                    switch state {
//                    case .available:
//                        return gpsSignal
//                    case .undetermined:
//                        return .init(value: (false, nil))
//                    case .denied, .restricted, .disabled:
//                        return .init(value: (false, nil))
//                    }
//                })
//        }
    }
    
}
