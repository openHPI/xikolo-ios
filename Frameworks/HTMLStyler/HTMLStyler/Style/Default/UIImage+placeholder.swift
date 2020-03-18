//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//
//  Based on the work of https://github.com/Cocoanetics/Swift-Examples/tree/master/Attachments
//

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
