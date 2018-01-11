//
//  CALayer+UIColor.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 12.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

extension CALayer {

    @IBInspectable var borderUIColor: UIColor? {
        get {
            guard let color = borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set(newColor) {
            borderColor = newColor?.cgColor
        }
    }

}
