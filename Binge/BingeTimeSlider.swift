//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class BingeTimeSlider: UISlider {

    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let trackHeight: CGFloat = 2
        let superRect = super.trackRect(forBounds: bounds)
        let heightDelta = trackHeight - superRect.height
        return CGRect(x: superRect.origin.x, y: superRect.origin.y - heightDelta / 2 - 0.5, width: superRect.width, height: trackHeight)
    }

    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var superRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        guard self.isHighlighted else { return superRect }
        let scaledShiftedValue = CGFloat(value) * (superRect.width) - (superRect.width) / 2
        superRect.origin.x += scaledShiftedValue
        return superRect
    }

}
