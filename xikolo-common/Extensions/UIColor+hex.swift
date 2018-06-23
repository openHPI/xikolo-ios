//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIColor {

    // Taken from https://gist.github.com/yannickl/16f0ed38f0698d9a8ae7
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0

        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let mask = 0x000000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            red = CGFloat(r) / 255.0
            green = CGFloat(g) / 255.0
            blue = CGFloat(b) / 255.0
        }

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

}
