//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UITableViewCell {

    func enable(_ enabled: Bool) {
        self.isUserInteractionEnabled = enabled
        for view in contentView.subviews {
            view.isUserInteractionEnabled = enabled
            view.alpha = enabled ? 1 : 0.5
        }
    }

}
