//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIView {

    func addDefaultPointerInteraction() {
        if #available(iOS 13.4, *) {
            let interaction = UIPointerInteraction(delegate: nil)
            self.addInteraction(interaction)
        } else {
            // not supported for iOS 13.3 and earlier
        }
    }

}
