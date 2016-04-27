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

    @IBAction func login(button: UIButton) {
        let email = emailField.text!
        let password = passwordField.text!

        UserProfileHelper.login(email, password: password) { (token: String?, error: NSError?) -> () in
            if token != nil {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                self.delegate?.didSuccessfullyLogin()
            } else {
                self.emailField.shake()
                self.passwordField.shake()
            }
        }
    }

}

protocol AbstractLoginViewControllerDelegate {

    func didSuccessfullyLogin()

}
