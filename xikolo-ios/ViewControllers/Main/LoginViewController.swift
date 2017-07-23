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
        loginButton.backgroundColor = Brand.TintColor
        emailField.becomeFirstResponder()
        
        #if OPENSAP || OPENWHO
            singleSignOnView.isHidden = false
            singleSignOnButton.backgroundColor = Brand.TintColor
            singleSignOnButton.setTitle(Brand.ButtonLabelSSO, for: .normal)
        #else
            singleSignOnView.isHidden = true
        #endif
    }

    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindLogin", sender: self)
    }

    @IBAction func registerButton(_ sender: AnyObject) {
        guard let url = URL(string: Routes.REGISTER_URL) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
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

    override func didSuccessfullyLogin() {
        super.didSuccessfullyLogin()
        performSegue(withIdentifier: "unwindLogin", sender: self)
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
