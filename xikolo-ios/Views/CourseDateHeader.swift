//
//  CourseDateHeader.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 15.05.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import UIKit

class CourseDateHeader : UITableViewHeaderFooterView {

    @IBOutlet var titleView: UILabel!
    @IBOutlet var titleBackgroundView: UIView!

    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!

}
