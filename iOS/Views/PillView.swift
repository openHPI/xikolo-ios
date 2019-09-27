//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class PillView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.layer.bounds.height / 2
        self.layer.masksToBounds = self.layer.cornerRadius > 0

        if #available(iOS 13, *) {
            self.layer.cornerCurve = .continuous
        }
    }

}
