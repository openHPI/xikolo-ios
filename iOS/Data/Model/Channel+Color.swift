//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

extension Channel {

    var color: UIColor? {
        return self.colorString.flatMap(UIColor.init(hexString:))
    }

    func colorWithFallback(to fallbackColor: UIColor) -> UIColor {
        guard let originalColor = self.color else { return fallbackColor }

        if #available(iOS 13, *) {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .light ? originalColor : fallbackColor
            }
        } else {
            return originalColor
        }
    }

}

//extension UIColor {
//
//    // See: https://www.w3.org/TR/WCAG20/#relativeluminancedef
//    var relativeLuminance: CGFloat {
//        let linearize: (CGFloat) -> CGFloat = { value in
//            if value <= 0.03928 {
//                return value / 12.92
//            } else {
//                return pow((value + 0.055) / 1.055, 2.4)
//            }
//        }
//
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        self.getRed(&red, green: &green, blue: &blue, alpha: nil)
//
//        return 0.2126 * linearize(red) + 0.7152 * linearize(green) + 0.0722 * linearize(blue)
//    }
//
//}
