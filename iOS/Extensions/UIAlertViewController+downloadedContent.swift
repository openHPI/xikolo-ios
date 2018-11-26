//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIAlertController {

    convenience init(deleteDownloadedContent action: ((UIAlertAction) -> Void)?) {
        let title = NSLocalizedString("settings.downloads.alert.delete.title", comment: "title for deleting downloaded content")
        let message = NSLocalizedString("settings.downloads.alert.delete.message", comment: "message for deleting downloaded content")
        self.init(title: title, message: message, preferredStyle: .alert)
        let deleteTitle = NSLocalizedString("global.alert.delete", comment: "title to delete alert")
        let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive, handler: action)
        self.addAction(deleteAction)
        self.addCancelAction()
    }

}
