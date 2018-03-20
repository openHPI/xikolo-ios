//
//  Created for xikolo-ios under MIT license.
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
