//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class DynamicSizeButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.adjustsFontForContentSizeCategory = true
    }

}
