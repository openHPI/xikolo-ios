//
//  Created for xikolo-ios under MIT license.
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
