//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SafariServices
import UIKit
import WebKit

class LoginViewController: UIViewController, WKUIDelegate {

    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var loginButton: LoadingButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var singleSignOnView: UIView!
    @IBOutlet private weak var singleSignOnButton: UIButton!
    @IBOutlet private weak var centerInputFieldsConstraints: NSLayoutConstraint!
    @IBOutlet private var textFieldBackgroundViews: [UIView]!

    weak var delegate: LoginDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.backgroundColor = Brand.default.colors.primary
        self.registerButton.backgroundColor = Brand.default.colors.primaryLight
        self.registerButton.tintColor = ColorCompatibility.secondaryLabel

        self.textFieldBackgroundViews.forEach { $0.layer.roundCorners(for: .default) }
        self.loginButton.layer.roundCorners(for: .default)
        self.registerButton.layer.roundCorners(for: .default)
        self.singleSignOnButton.layer.roundCorners(for: .default)

        self.loginButton.layer.roundCorners(for: .default)
        self.registerButton.layer.roundCorners(for: .default)
        self.singleSignOnButton.layer.roundCorners(for: .default)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustViewForKeyboardShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustViewForKeyboardHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        if let title = Brand.default.singleSignOn?.buttonTitle {
            self.singleSignOnView.isHidden = false
            self.singleSignOnButton.backgroundColor = Brand.default.colors.primary
            self.singleSignOnButton.setTitle(title, for: .normal)
        } else {
            self.singleSignOnView.isHidden = true
        }

    }

    @IBAction private func dismiss() {
        self.presentingViewController?.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction private func login() {
        guard let email = emailField.text, let password = passwordField.text else {
            self.emailField.shake()
            self.passwordField.shake()
            return
        }

        self.loginButton.startAnimation()
        let dispatchTime = 500.milliseconds.fromNow
        UserProfileHelper.shared.login(email, password: password).earliest(at: dispatchTime).onComplete { [weak self] _ in
            self?.loginButton.stopAnimation()
        }.onSuccess { [weak self] _ in
            self?.delegate?.didSuccessfullyLogin()
            self?.presentingViewController?.dismiss(animated: trueUnlessReduceMotionEnabled)
        }.onFailure { [weak self] _ in
            self?.emailField.shake()
            self?.passwordField.shake()
        }
    }

    @IBAction private func register() {
        let safariVC = SFSafariViewController(url: Routes.register)
        safariVC.preferredControlTintColor = Brand.default.colors.window
        self.present(safariVC, animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction private func forgotPassword() {
        let safariVC = SFSafariViewController(url: Routes.localizedForgotPasswordURL)
        safariVC.preferredControlTintColor = Brand.default.colors.window
        self.present(safariVC, animated: true)
    }

    @IBAction private func singleSignOn() {
        self.performSegue(withIdentifier: R.segue.loginViewController.showSSOWebView, sender: self)
    }

    @IBAction private func tappedBackground() {
        self.emailField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.loginViewController.showSSOWebView(segue: segue) {
            typedInfo.destination.loginDelegate = self.delegate
            typedInfo.destination.url = Routes.singleSignOn
        }
    }

    @objc func adjustViewForKeyboardShow(_ notification: Notification) {
        // On some devices, the keyboard can overlap with some UI elements. To prevent this, we move
        // the `inputContainer` upwards. The other views will reposition accordingly.
        let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.emailField.layoutIfNeeded()
        self.passwordField.layoutIfNeeded()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
        } else if textField === self.passwordField {
            self.login()
        }

        return true
    }

}

protocol LoginDelegate: AnyObject {

    func didSuccessfullyLogin()

}
