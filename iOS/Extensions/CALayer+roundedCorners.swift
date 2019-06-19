//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension CALayer {

    enum CornerStyle: CGFloat {
        case `default` = 6
        case inner = 4
    }

    func roundCorners(for style: CALayer.CornerStyle, masksToBounds: Bool = true) {
        self.masksToBounds = masksToBounds
        self.cornerRadius = style.rawValue

        if #available(iOS 13, *) {
            self.cornerCurve = .continuous
        }
    }

}
