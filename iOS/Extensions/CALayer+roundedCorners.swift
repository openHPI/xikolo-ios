//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension CALayer {

    struct CornerStyle: Hashable, Equatable, RawRepresentable {

        static let searchField = CALayer.CornerStyle(rawValue: 10)
        static let `default` = CALayer.CornerStyle(rawValue: 6)
        static let inner = CALayer.CornerStyle(rawValue: 4)

        let rawValue: CGFloat

    }

    func roundCorners(for style: CALayer.CornerStyle, masksToBounds: Bool = true) {
        self.masksToBounds = masksToBounds
        self.cornerRadius = style.rawValue

        if #available(iOS 13, *) {
            self.cornerCurve = .continuous
        }
    }

}
