//
//  BingePaddedLabel.swift
//  Binge
//
//  Created by Max Bothe on 29.01.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import UIKit

class BingePaddedLabel: UILabel {

    var verticalPadding: CGFloat = 3
    var horizontalPadding: CGFloat = 6

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        let newWidth = superSize.width + 2 * self.horizontalPadding
        let newHeight = superSize.height + 2 * self.verticalPadding
        return CGSize(width: newWidth, height: newHeight)
    }

}
