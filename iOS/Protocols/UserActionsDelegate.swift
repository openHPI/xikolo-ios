//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import UIKit

protocol UserActionsDelegate: AnyObject {

    func showAlert(with actions: [UIAlertAction], withTitle title: String?, on anchor: UIView)
    func showAlertSpinner(title: String?, task: () -> Future<Void, XikoloError>) -> Future<Void, XikoloError>

}
