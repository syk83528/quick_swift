//
//  IWDevice.swift
//  IWBaseKits
//
//  Created by 未来 on 2019/4/3.
//  Copyright © 2019 iWECon. All rights reserved.
//

import UIKit

public struct Device {
    private init() { }
    
    public static let iPad: Bool = {
        return UIDevice.current.model == "iPad"
    }()
    
    public static let iPhone: Bool = {
        return UIDevice.current.model == "iPhone"
    }()
    
    public static let hasNotch: Bool = {
        if #available(iOS 11.0, *) {
            guard let safeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets else {
                return false
            }
            return safeAreaInsets.bottom > 0.0
        }
        return false
    }()
    
    public static let isSimulator: Bool = {
        var isSim = false
#if arch(i386) || arch(x86_64)
        isSim = true
#endif
        return isSim
    }()
    
    public static let version = UIDevice.current.systemVersion
    
    public static let platform = UIDevice.current.systemName
    public static let aboutName = UIDevice.current.name
    
    public static let localPhoneModel = UIDevice.current.localizedModel
}

extension Device {
    
    /// (返回机型内部标识, 例如: iPhone9,1).
    public static var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    public static var iPhoneModel: Int {
        let device = Device.modelIdentifier
        if device.hasPrefix("iPhone") {
            guard let deviceString = device.components(separatedBy: ",").first,
                  let modelString = deviceString.components(separatedBy: "iPhone").last else {
                      return 1
                  }
            return modelString.int
        }
        return 1
    }
    
    // 参考: https://www.theiphonewiki.com/wiki/Models
    /// (返回机型, 例如: iPhone 7).
    public static var modelName: String {
        let identifier = Device.modelIdentifier
        switch identifier {
        case "iPod1,1":                                 return "iPod touch"
        case "iPod2,1":                                 return "iPod touch (2nd)"
        case "iPod3,1":                                 return "iPod touch (3rd)"
        case "iPod4,1":                                 return "iPod touch (4th)"
        case "iPod5,1":                                 return "iPod touch (5th)"
        case "iPod7,1":                                 return "iPod touch (6th)"
        case "iPod9,1":                                 return "iPod touch (7th)"
            
        case "iPhone1,1":                               return "iPhone"
        case "iPhone1,2":                               return "iPhone 3G"
        case "iPhone2,1":                               return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone Xs"
        case "iPhone11,4", "iPhone11,6":                return "iPhone Xs Max"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
        case "iPhone12,8":                              return "iPhone SE 2nd"
        case "iPhone13,1":                              return "iPhone 12 mini"
        case "iPhone13,2":                              return "iPhone 12"
        case "iPhone13,3":                              return "iPhone 12 Pro"
        case "iPhone13,4":                              return "iPhone 12 Pro Max"
        case "iPhone14,2":                              return "iPhone 13 Pro"
        case "iPhone14,3":                              return "iPhone 13 Pro Max"
        case "iPhone14,4":                              return "iPhone 13 mini"
        case "iPhone14,5":                              return "iPhone 13"
            
        case "iPad1,1":                                 return "iPad"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3rd"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4th"
        case "iPad6,11", "iPad6,12":                    return "iPad 5th"
        case "iPad7,5", "iPad7,6":                      return "iPad 6th"
        case "iPad7,11", "iPad7,12":                    return "iPad 7th"
        case "iPad11,6", "iPad11,7":                    return "iPad 8th"
        case "iPad12,1", "iPad12,2":                    return "iPad 9th"
            
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad11,3", "iPad11,4":                    return "iPad Air 3rd"
        case "iPad13,1", "iPad13,2":                    return "iPad Air 4th"
            
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad11,1", "iPad11,2":                    return "iPad Mini 5th"
        case "iPad14,1", "iPad14,2":                    return "iPad Mini 6th"
            
        case "iPad6,3", "iPad6,4":                              return "iPad Pro 9.7-inch"
            
        case "iPad7,3", "iPad7,4":                              return "iPad Pro 10.5-inch"
            
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":        return "iPad Pro 11-inch"
        case "iPad8,9", "iPad8,10":                             return "iPad Pro 11-inch 2nd"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":    return "iPad Pro 11-inch 3rd"
            
        case "iPad6,7", "iPad6,8":                              return "iPad Pro 12.9-inch"
        case "iPad7,1", "iPad7,2":                              return "iPad Pro 12.9-inch 2nd"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":        return "iPad Pro 12.9-inch 3rd"
        case "iPad8,11", "iPad8,12":                            return "iPad Pro 12.9-inch 4th"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":  return "iPad Pro 12.9-inch 5th"
            
        case "AppleTV1,1":                              return "Apple TV"
        case "AppleTV2,1":                              return "Apple TV 2nd"
        case "AppleTV3,1", "AppleTV3,2":                return "Apple TV 3rd"
        case "AppleTV5,3":                              return "Apple TV 4th"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AppleTV11,1":                             return "Apple TV 4K 2nd"
            
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}



extension Device {
    
    enum Network: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
        
        // case ipv4 = "ipv4"
        // case ipv6 = "ipv6"
        // case en0 = "en0" wifi网卡
        // case en2 = "en2" 有线网卡1
        // case en3 = "en3" 有线网卡2
        // case en4 = "en4" 有线网卡3
        // case en...
        // case pdp_ip0 = "pdp_ip0" 蜂窝数据
        // case pdp_ip1 = "pdp_ip1" 蜂窝数据
        // case pdp_ip2 = "pdp_ip2" 蜂窝数据
        // case pdp_ip3 = "pdp_ip3" 蜂窝数据
        // case pdp_ip...
        
    }
    
    /// 获取 设备网卡IP
    static func IPAddress(for network: Device.Network) -> String? {
        var address: String?
        
        // 获取设备网卡列表
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    static var networkIP: String?
    
    /// 获取 外网ip
    static func networkIPAddress() {
        DispatchQueue.global().async {
            
            guard let ipURL = URL(string: "https://www.taobao.com/help/getip.php") else {
                return
            }
            
            do {
                let ip = try String(contentsOf: ipURL, encoding: .utf8)
                log("networkIPAddress ip:\(ip)")
                if let t = ip.ipAddress {
                    networkIP = t
                }
            } catch _ {
                
            }
        }
    }
    
}
