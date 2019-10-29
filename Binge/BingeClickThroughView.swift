//
//  BingeClickThroughView.swift
//  Binge
//
//  Created by Max Bothe on 21.01.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import UIKit

class BingeClickThroughView: UIView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in self.subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: self.convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }

}
