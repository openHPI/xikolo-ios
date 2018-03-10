//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class AbstractLoginViewController : UIViewController {

    @IBOutlet weak var emailField : UITextField!
    @IBOutlet weak var passwordField : UITextField!

    var delegate : AbstractLoginViewControllerDelegate?

    @IBAction func login() {
        guard let email = emailField.text, let password = passwordField.text else {
            self.emailField.shake()
            self.passwordField.shake()
            return
        }

        UserProfileHelper.login(email, password: password).onSuccess { [weak self] token in
            self?.handleLoginSuccess(with: token)
        }.onFailure { [weak self] error in
            self?.handleLoginFailure(with: error)
        }
    }

    func handleLoginSuccess(with token: String) {
        self.delegate?.didSuccessfullyLogin()
        self.presentingViewController?.dismiss(animated: true)
    }

    func handleLoginFailure(with error: Error) {
        self.emailField.shake()
        self.passwordField.shake()

        #if os(tvOS)
        if XikoloError.authenticationError != error {
            self.handleError(error)
        }
        #endif
    }

}

protocol AbstractLoginViewControllerDelegate {

    func didSuccessfullyLogin()

}
