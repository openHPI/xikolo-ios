//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
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
