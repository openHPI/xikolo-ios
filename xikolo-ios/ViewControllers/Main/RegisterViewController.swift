//
//  RegisterViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 25.06.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class RegisterViewController : AbstractLoginViewController, UITextFieldDelegate {

    @IBOutlet weak var registerButton: UIButton!
    @IBAction func dismissAction(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func registerButton(sender: AnyObject) {
        let url = NSURL(string: Routes.REGISTER_URL)
        UIApplication.sharedApplication().openURL(url!)
    }

    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.backgroundColor = Brand.tintColor
        emailField.becomeFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
