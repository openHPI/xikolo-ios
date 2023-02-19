//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit
import SwiftUI

extension UIColor {
  /**
   Create a lighter color
   */
    func lighter(by percentage: CGFloat = 0.3) -> UIColor {
        return UIColor.blend(color1: self, intensity1: 1 - percentage, color2: ColorCompatibility.systemBackground, intensity2: percentage)
    }

  /**
   Create a darker color
   */
    func darker(by percentage: CGFloat = 0.3) -> UIColor {
        return UIColor.blend(color1: self, intensity1: 1 - percentage, color2: ColorCompatibility.label, intensity2: percentage)
    }

    static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor, intensity2: CGFloat = 0.5) -> UIColor {
        let total = intensity1 + intensity2
        let l1 = intensity1/total
        let l2 = intensity2/total
        guard l1 > 0 else { return color2}
        guard l2 > 0 else { return color1}
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(red: l1*r1 + l2*r2, green: l1*g1 + l2*g2, blue: l1*b1 + l2*b2, alpha: l1*a1 + l2*a2)
    }
}

@available(iOS 14.0, *)
extension Color {
    public func lighter(by amount: CGFloat = 0.3) -> Self { Self(UIColor(self).lighter(by: amount)) }
    public func darker(by amount: CGFloat = 0.3) -> Self { Self(UIColor(self).darker(by: amount)) }
}
