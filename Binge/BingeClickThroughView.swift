//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class BingeClickThroughView: UIView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.subviews.contains {
            !$0.isHidden && $0.isUserInteractionEnabled && $0.point(inside: self.convert(point, to: $0), with: event)
        }
    }

}
