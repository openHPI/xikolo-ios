//
//  RegisterViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 25.06.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController : AbstractLoginViewController, WKUIDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var singleSignOnView: UIView!
    @IBOutlet weak var singleSignOnButton: UIView!
    @IBOutlet var parentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.backgroundColor = Brand.TintColor
        emailField.becomeFirstResponder()
        #if OPENHPI
            singleSignOnView.isHidden = false
            singleSignOnButton.backgroundColor = Brand.TintColor
        #else
            singleSignOnView.isHidden = true
        #endif
    }

    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func registerButton(_ sender: AnyObject) {
        let url = URL(string: Routes.REGISTER_URL)
        UIApplication.shared.openURL(url!)
    }

    @IBAction func singleSignIn(_ sender: UIButton) {
        let url = URL(string: Routes.SSO_URL)!
        UIApplication.shared.openURL(url)
//        let request = URLRequest(url: url)
//        let wkViewController = CustomHeaderWebView(frame: .zero)
//        wkViewController.header = ["X-User-Platform" : "iOS"]
//        wkViewController.uiDelegate = self
//        view = wkViewController
//        wkViewController.load(request)
    }

}

extension LoginViewController : UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
