//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class BingeTimeSlider: UISlider {

    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.trackRect(forBounds: bounds)
        let trackHeight = 3.0
        let heightDelta = trackHeight - superRect.height
        return CGRect(x: superRect.origin.x, y: superRect.origin.y - heightDelta / 2, width: superRect.width, height: superRect.height + heightDelta)
    }

}
