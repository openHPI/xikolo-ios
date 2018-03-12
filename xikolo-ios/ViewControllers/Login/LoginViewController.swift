//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SafariServices
import SimpleRoundedButton
import UIKit
import WebKit

class LoginViewController: AbstractLoginViewController, WKUIDelegate {

    @IBOutlet private weak var loginButton: SimpleRoundedButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var singleSignOnView: UIView!
    @IBOutlet private weak var singleSignOnButton: UIButton!
    @IBOutlet private weak var centerInputFieldsConstraints: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.backgroundColor = Brand.TintColor
        self.registerButton.backgroundColor = Brand.TintColor.withAlphaComponent(0.2)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustViewForKeyboardShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustViewForKeyboardHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)

        #if OPENSAP || OPENWHO
            singleSignOnView.isHidden = false
            singleSignOnButton.backgroundColor = Brand.TintColor
            singleSignOnButton.setTitle(Brand.ButtonLabelSSO, for: .normal)
        #else
            singleSignOnView.isHidden = true
        #endif
    }

    override func login() {
        loginButton.startAnimating()
        super.login()
    }

    override func handleLoginSuccess(with token: String) {
        loginButton.stopAnimating()
        super.handleLoginSuccess(with: token)
    }

    override func handleLoginFailure(with error: Error) {
        loginButton.stopAnimating()
        super.handleLoginFailure(with: error)
    }

    @IBAction func dismiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func register() {
        guard let url = URL(string: Routes.REGISTER_URL) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = Brand.windowTintColor
        self.present(safariVC, animated: true)
    }

    @IBAction func forgotPassword() {
        let safariVC = SFSafariViewController(url: Routes.localizedForgotPasswordURL)
        safariVC.preferredControlTintColor = Brand.windowTintColor
        self.present(safariVC, animated: true)
    }

    @IBAction func singleSignOn() {
        self.performSegue(withIdentifier: "ShowSSOWebView", sender: self)
    }

    @IBAction func tappedBackground() {
        self.emailField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSSOWebView" {
            let vc = segue.destination.require(toHaveType: WebViewController.self)
            vc.url = Routes.SSO_URL
            vc.loginDelegate = self.delegate

            // Delete all cookies since cookies are not shared among applications in iOS.
            let cookieStorage = HTTPCookieStorage.shared
            for cookie in cookieStorage.cookies ?? [] {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }

    @objc func adjustViewForKeyboardShow(_ notification: Notification) {
        // On some devices, the keyboard can overlap with some UI elements. To prevent this, we move
        // the `inputContainer` upwards. The other views will reposition accordingly.
        let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardHeight = keyboardFrameValue?.cgRectValue.size.height ?? 0.0

        let contentInset: CGFloat
        if #available(iOS 11.0, *) {
            contentInset = self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom
        } else {
            contentInset = self.topLayoutGuide.length + self.bottomLayoutGuide.length
        }

        let viewHeight = self.view.frame.size.height - contentInset

        let overlappingOffset = 0.5 * viewHeight - keyboardHeight - self.emailField.frame.size.height - 8.0
        self.centerInputFieldsConstraints.constant = min(overlappingOffset, 0)  // we only want to move the container upwards

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func adjustViewForKeyboardHide(_ notification: Notification) {
        self.centerInputFieldsConstraints.constant = 0

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

}

extension LoginViewController: UITextFieldDelegate {

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

