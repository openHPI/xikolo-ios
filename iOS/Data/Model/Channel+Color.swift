//
//  Created for xikolo-ios under GPL-3.0 license.
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
