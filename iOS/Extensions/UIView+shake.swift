//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIView {

    func shake() {
#if os(iOS)
        let deltaX = 5.0 as CGFloat
#else
        let deltaX = 10.0 as CGFloat
#endif
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - deltaX, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + deltaX, y: center.y))
        layer.add(animation, forKey: "position")
    }

}
