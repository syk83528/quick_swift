//
//  ActionSheet.swift
//  spsd
//
//  Created by Wildog on 12/25/19.
//  Copyright © 2019 Wildog. All rights reserved.
//

import UIKit

extension ActionSheet {
    func show(_ items: [ActionSheetItem], on view: UIView = OverlayWindow.shared, options: ActionSheetOption = [.dimBackground, .showCancelButton]) {
        show(items, on: view, withOptions: options)
    }
}
