//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

extension UITextView {

    func setMarkdownWithImages(from markdown: String?, minimumHeightContraint: NSLayoutConstraint) {
        if let markdown = markdown {
            self.attributedText = MarkdownHelper.attributedStringWithImages(for: markdown) {
                // Set minimum height manually as the size of a UITextView inside UIStackView will not be updated automatically
                minimumHeightContraint.constant = self.intrinsicContentSize.height
            }

            self.isHidden = false
        } else {
            self.isHidden = true
        }
    }

}
