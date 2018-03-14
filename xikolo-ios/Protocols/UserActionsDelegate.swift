//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

protocol UserActionsDelegate: class {

    func showAlert(with actions: [UIAlertAction], withTitle title: String?, on anchor: UIView)

}
