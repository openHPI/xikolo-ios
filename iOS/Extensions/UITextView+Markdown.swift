//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

extension UITextView {

    func setMarkdownWithImages(from markdown: String?) {
        if let markdown = markdown {
            self.attributedText = MarkdownHelper.attributedStringWithImages(for: markdown) { [weak self] in
                // If the UITextView is placed inside a UIStackView, the intrinsic content size has to be invalidated manually
                self?.invalidateIntrinsicContentSize()
            }

            self.isHidden = false
        } else {
            self.isHidden = true
        }
    }

}
