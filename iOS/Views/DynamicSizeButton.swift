//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class DynamicSizeButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.adjustsFontForContentSizeCategory = true
    }

}
