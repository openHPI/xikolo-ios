//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class ShadowContainerView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.15
        self.layer.shadowRadius = 5.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: CALayer.CornerStyle.default.rawValue).cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: CALayer.CornerStyle.default.rawValue).cgPath
    }

}
