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
        #if OPENHPI // move to brand config
            singleSignOnView.isHidden = true
        #else
            singleSignOnView.isHidden = false
            singleSignOnButton.backgroundColor = Brand.TintColor
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
        performSegue(withIdentifier: "ShowSSOWebView", sender: self)
//        let url = URL(string: Routes.SSO_URL)!
//        let request = URLRequest(url: url)
//        let wkViewController = CustomHeaderWebView(frame: .zero)
//        wkViewController.header = ["X-User-Platform" : "iOS"]
//        wkViewController.uiDelegate = self
//       
//        view = wkViewController
//        wkViewController.load(request)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSSOWebView" {
            let vc = segue.destination as! WebViewController
            vc.url = Routes.SSO_URL
        }
    }

}

extension LoginViewController : UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
