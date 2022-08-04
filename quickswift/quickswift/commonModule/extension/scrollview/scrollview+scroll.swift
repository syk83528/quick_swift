//
//  scrollview+scroll.swift
//  quickswift
//
//  Created by suyikun on 2022/8/4.
//

import Foundation
import UIKit

public extension UIScrollView {
     func scrollToBottom(animated: Bool = true, triggerByUser: Bool = true) {
        if animated, self.isTracking, self.isDragging {
            print("......")
            return
        }
        guard self.contentSize.height > self.height + self.bounds.origin.y - self.contentInset.bottom else {
            print("contentSizeH: \(self.contentSize.height)")
            print("height: \(self.height)")
            print("......")
            return
        }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)
         print("bottomOffset: \(self.contentSize.height)")
        if animated {
            if triggerByUser {
                print("111111")
                self.setContentOffset(bottomOffset, animated: true)
            } else {
                if self.isDecelerating {
                    self.setContentOffset(self.contentOffset, animated: false)
                }
                print("22222")
                UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .beginFromCurrentState], animations: {
                    self.setContentOffset(bottomOffset, animated: false)
                }, completion: nil)
            }
        } else {
            self.setContentOffset(bottomOffset, animated: false)
        }
    }
}
