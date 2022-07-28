//
//  DebugHandler.swift
//  quick
//
//  Created by suyikun on 2021/5/5.
//
import UIKit
import AVFoundation
#if DEBUG
import FLEX
#endif

class DebugHandler: NSObject {
    static let shared = DebugHandler()
    
    override init() {
        super.init()
        
        #if DEBUG || ENVS
        NotificationCenter.default.reactive.notifications(forName: UIWindow.didBecomeKeyNotification).take(duringLifetimeOf: self).observeValues {[unowned self] (x) in
            guard let window = x.object as? UIWindow else { return }
            window.gestureRecognizers?.filter({
                (($0 as? UITapGestureRecognizer)?.numberOfTouchesRequired == 2) ||
                (($0 as? UISwipeGestureRecognizer)?.numberOfTouchesRequired == 2)
            }).forEach { window.removeGestureRecognizer($0) }
            
            _ = UITapGestureRecognizer(target: self, action: #selector(self.showFlex(_:))).then {
                $0.delegate = self
                $0.numberOfTouchesRequired = 2
                window.addGestureRecognizer($0)
            }

            _ = UISwipeGestureRecognizer(target: self, action: #selector(self.showDebugSheet(_:))).then {
                $0.delegate = self
                $0.numberOfTouchesRequired = 2
                $0.direction = .down
                window.addGestureRecognizer($0)
            }
            
            _ = UISwipeGestureRecognizer(target: self, action: #selector(self.showEnvSheet(_:))).then {
                $0.delegate = self
                $0.numberOfTouchesRequired = 2
                $0.direction = .up
                window.addGestureRecognizer($0)
            }
        }
        #endif
    }
    
    @objc func showFlex(_ gesture: UITapGestureRecognizer) {
        #if DEBUG
        guard gesture.state == .recognized else { return }
        FLEXManager.shared.showExplorer()
        #endif
    }

    @objc func showDebugSheet(_ gesture: UISwipeGestureRecognizer) {
        #if DEBUG
        guard gesture.state == .recognized else { return }
        DebugSheet.show()
        #endif
    }
    
    @objc func showEnvSheet(_ gesture: UISwipeGestureRecognizer) {
        #if DEBUG || ENVS
        guard gesture.state == .recognized else { return }
        EnvSheet.show()
        #endif
    }
}

extension DebugHandler: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
