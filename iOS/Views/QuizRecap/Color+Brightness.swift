//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import UIKit

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
        let lightness1 = intensity1 / total
        let lightness2 = intensity2 / total
        guard lightness1 > 0 else { return color2}
        guard lightness2 > 0 else { return color1}
        var (red1, green1, blue1, alpha1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (red2, green2, blue2, alpha2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return UIColor(red: lightness1 * red1 + lightness2 * red2,
                       green: lightness1 * green1 + lightness2 * green2,
                       blue: lightness1 * blue1 + lightness2 * blue2,
                       alpha: lightness1 * alpha1 + lightness2 * alpha2)
    }
}

@available(iOS 14.0, *)
extension Color {
    public func lighter(by amount: CGFloat = 0.3) -> Self { Self(UIColor(self).lighter(by: amount)) }
    public func darker(by amount: CGFloat = 0.3) -> Self { Self(UIColor(self).darker(by: amount)) }
}
