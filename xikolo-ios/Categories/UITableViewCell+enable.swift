//
//  UITableViewCell+enable.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 29.10.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

extension UITableViewCell {

    func enable(_ on: Bool) {
        self.isUserInteractionEnabled = on
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }

}
