//
//  AbstractTabContentViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class AbstractTabContentViewController: UIViewController {

    @IBOutlet var loginButton: UIBarButtonItem?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton = navigationItem.rightBarButtonItem
        navigationItem.hidesBackButton = true

        NotificationCenter.default.addObserver(self, selector: #selector(updateUIAfterLoginLogoutAction), name: NotificationKeys.loginSuccessfulKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUIAfterLoginLogoutAction), name: NotificationKeys.logoutSuccessfulKey, object: nil)
        updateUIAfterLoginLogoutAction()
    }

    func updateUIAfterLoginLogoutAction() {
        if UserProfileHelper.isLoggedIn() {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = loginButton
        }
    }

}
