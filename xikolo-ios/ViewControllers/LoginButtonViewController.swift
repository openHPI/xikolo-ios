//
//  AbstractTabContentViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

protocol LoginButtonViewController {

    var loginButton: UIBarButtonItem! { get set }

    func addLoginObserver(with selector: Selector)

    func removeLoginObserver()

    func updateLoginButton()

}


extension LoginButtonViewController where Self: UIViewController {

    func addLoginObserver(with selector: Selector) {
        self.navigationItem.hidesBackButton = true

        NotificationCenter.default.addObserver(self, selector: selector, name: NotificationKeys.loginSuccessfulKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: selector, name: NotificationKeys.logoutSuccessfulKey, object: nil)
        self.updateLoginButton()
    }

    func removeLoginObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    func updateLoginButton() {
        if UserProfileHelper.isLoggedIn() {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = self.loginButton
        }
    }

}
