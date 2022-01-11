//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIViewController {

    var appNavigator: AppNavigator? {
        if #available(iOS 13, *) {
            let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
            return sceneDelegate?.appNavigator
        } else {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            return appDelegate?.appNavigator
        }
    }

}
