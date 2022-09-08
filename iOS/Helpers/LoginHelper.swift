//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common

enum LoginHelper {

    static func loginNavigationViewController(loginDelegate: LoginDelegate?) -> UIViewController {
        let loginNavigationController: UINavigationController = {
            if Brand.default.singleSignOn?.disabledPasswordLogin ?? false {
                return R.storyboard.login.ssoLoginNavigationController().require()
            } else {
                return R.storyboard.login.passwordLoginNavigationController().require()
            }
        }()

        let firstViewController = loginNavigationController.viewControllers.first.require()
        let loginViewController = firstViewController.require(toHaveType: LoginViewController.self)
        loginViewController.loginDelegate = loginDelegate

        if let webViewController = loginViewController as? WebViewController  {
            webViewController.url = Routes.singleSignOn
        }

        return loginNavigationController
    }

}
