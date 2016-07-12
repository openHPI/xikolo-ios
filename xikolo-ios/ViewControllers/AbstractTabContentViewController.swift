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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton = navigationItem.rightBarButtonItem
        navigationItem.hidesBackButton = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUIAfterLoginLogoutAction), name: NotificationKeys.loginSuccessfulKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUIAfterLoginLogoutAction), name: NotificationKeys.logoutSuccessfulKey, object: nil)
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
