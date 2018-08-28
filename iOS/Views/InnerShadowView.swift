//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class InnerShadowView: UIView {

    lazy var innerShadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        shadowLayer.shadowOpacity = 0.1
        shadowLayer.shadowRadius = 14
        shadowLayer.fillRule = kCAFillRuleEvenOdd
        return shadowLayer
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.addSublayer(self.innerShadowLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let shadowPath = CGMutablePath()
        let inset = -self.innerShadowLayer.shadowRadius * 2.0
        shadowPath.addRect(self.bounds.insetBy(dx: inset, dy: inset))
        shadowPath.addRect(self.bounds)
        self.innerShadowLayer.path = shadowPath
    }

}
