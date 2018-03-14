//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIAlertController {

    static var cancelAction: UIAlertAction {
        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)
        return cancelAction
    }

    func addCancelAction() {
        self.addAction(UIAlertController.cancelAction)
    }

}
