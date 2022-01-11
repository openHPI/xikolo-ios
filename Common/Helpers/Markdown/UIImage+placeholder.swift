//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIImage {

    static func placeholder(withColor color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        color.setFill()
        UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size)).fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image!
    }

}
