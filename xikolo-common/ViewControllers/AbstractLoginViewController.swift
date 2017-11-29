//
//  AbstractLoginViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 27.04.16.
//  Copyright © 2016 HPI. All rights reserved.
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
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func handleLoginFailure(with error: Error) {
        if case XikoloError.authenticationError = error {
            self.emailField.shake()
            self.passwordField.shake()
        } else {
            #if os(tvOS)
                self.handleError(error)
            #endif
            // TODO (iOS): Error handling
        }
    }

}

protocol AbstractLoginViewControllerDelegate {

    func didSuccessfullyLogin()

}
