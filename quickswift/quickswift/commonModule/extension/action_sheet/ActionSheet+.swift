//
//  ActionSheet+.swift
//  quick
//
//  Created by suyikun on 2021/8/9.
//

import Foundation


extension UIAlertController {
    static func show(title: String? = nil, message: String? = nil, _ actions: [UIAlertAction]) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for action in actions {
            vc.addAction(action)
        }
        UIViewController.current?.present(vc, animated: true, completion: nil)
    }
}
