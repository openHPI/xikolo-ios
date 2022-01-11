//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIAlertController {

    func addCancelAction(handler: ((UIAlertAction) -> Void)? = nil) {
        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: handler)
        self.addAction(cancelAction)
    }

}
