//
//  UIView+shake.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 27.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

extension UIView {

    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(center.x - 2.0, center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(center.x + 2.0, center.y))
        layer.addAnimation(animation, forKey: "position")
    }

}
