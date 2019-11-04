//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

// Workaround for a bug in Xcode 11.2
// See https://forums.developer.apple.com/thread/125287
class FixedTextView: UITextView {
    required init?(coder: NSCoder) {
        if #available(iOS 13.2, *) {
            super.init(coder: coder)
        }
        else {
            super.init(frame: .zero, textContainer: nil)
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.contentMode = .scaleToFill

            self.isScrollEnabled = false   // causes expanding height

            // Auto Layout
//            self.translatesAutoresizingMaskIntoConstraints = false
//            self.font = UIFont(name: "HelveticaNeue", size: 18)
        }
    }
}
