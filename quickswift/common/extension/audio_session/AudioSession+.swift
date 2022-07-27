//
//  AudioSession+.swift
//  spsd
//
//  Created by Wildog on 2/12/20.
//  Copyright © 2020 Wildog. All rights reserved.
//

import UIKit
import AVFoundation

private var otherAudioPlaying = false

public extension AVAudioSession {
    static func prepare(category: AVAudioSession.Category = .playback, options: AVAudioSession.CategoryOptions = [], continuous: Bool = false, activate: Bool = false) {
        var options = options
        var category = category
//        if LiveManager.shared.isPushing {
//            category = .playAndRecord
//            options.insert(.defaultToSpeaker)
//        } else if LiveManager.shared.isPlaying {
//            options.insert(.mixWithOthers)
//        }
        if !continuous {
            otherAudioPlaying = AVAudioSession.sharedInstance().isOtherAudioPlaying
        }
        try? AVAudioSession.sharedInstance().setCategory(category, options: options)
        if activate {
            try? AVAudioSession.sharedInstance().setActive(activate, options: [])
        }
    }
    
    static func finish() {
        if !otherAudioPlaying {
            return
        }
//        if LiveManager.shared.isPlaying || LiveManager.shared.isPushing {
//            return
//        }
        Common.Queue.async {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }
    
    static var isHeadphonesConnected: Bool {
        for output in AVAudioSession.sharedInstance().currentRoute.outputs {
            switch output.portType {
            case .headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE, .airPlay:
                return true
            default:
                break
            }
        }
        return false
    }
}
