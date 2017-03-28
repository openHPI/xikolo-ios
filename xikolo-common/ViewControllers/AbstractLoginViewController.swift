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

    @IBAction func login(_ button: UIButton) {
        let email = emailField.text!
        let password = passwordField.text!

        UserProfileHelper.login(email, password: password).onSuccess { token in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            self.didSuccessfullyLogin()
        }.onFailure { error in
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

    func didSuccessfullyLogin() {
        CourseHelper.refreshCourses()
        EnrollmentHelper.syncEnrollments()

        delegate?.didSuccessfullyLogin()
    }

}

protocol AbstractLoginViewControllerDelegate {

    func didSuccessfullyLogin()

}
