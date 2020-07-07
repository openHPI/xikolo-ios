//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit


// TODO: remove
protocol UserActionsDelegate: AnyObject {

    func showAlert(with actions: [UIAlertAction], title: String?, on anchor: UIView)
    func showAlert(with actions: [UIAlertAction], title: String?, message: String?, on anchor: UIView)
    func showAlertSpinner(title: String?, task: () -> Future<Void, XikoloError>) -> Future<Void, XikoloError>

}

extension UserActionsDelegate {

    func showAlert(with actions: [UIAlertAction], title: String?, on anchor: UIView) {
        self.showAlert(with: actions, title: title, message: nil, on: anchor)
    }

    func showAlertSpinner(title: String?, task: () -> Future<Void, XikoloError>) -> Future<Void, XikoloError> {
        return Future(value: ())
    }

}
