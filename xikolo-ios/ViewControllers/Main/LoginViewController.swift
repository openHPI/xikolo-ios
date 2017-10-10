//
//  RegisterViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 25.06.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class LoginViewController : AbstractLoginViewController, WKUIDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var singleSignOnView: UIView!
    @IBOutlet weak var singleSignOnButton: UIButton!
    @IBOutlet var parentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.backgroundColor = Brand.TintColor
        self.registerButton.backgroundColor = Brand.TintColor.withAlphaComponent(0.2)

        #if OPENSAP || OPENWHO
            singleSignOnView.isHidden = false
            singleSignOnButton.backgroundColor = Brand.TintColor
            singleSignOnButton.setTitle(Brand.ButtonLabelSSO, for: .normal)
        #else
            singleSignOnView.isHidden = true
        #endif
    }

    @IBAction func dismiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func register() {
        guard let url = URL(string: Routes.REGISTER_URL) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = Brand.TintColor
        self.present(safariVC, animated: true)
    }

    @IBAction func singleSignOn() {
        self.performSegue(withIdentifier: "ShowSSOWebView", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSSOWebView" {
            let vc = segue.destination as! WebViewController
            vc.url = Routes.SSO_URL

            // Delete all cookies since cookies are not shared among applications in iOS.
            let cookieStorage = HTTPCookieStorage.shared
            for cookie in cookieStorage.cookies ?? [] {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }

}

extension LoginViewController : UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
        } else if textField === self.passwordField {
            self.login()
            textField.resignFirstResponder()
        }
        return true
    }

}
