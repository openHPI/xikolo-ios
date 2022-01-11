//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class InnerPillLabel: UILabel {

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        let newWidth = superSize.width + superSize.height
        return CGSize(width: newWidth, height: superSize.height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textAlignment = .center
    }

}
