//
//  LoginViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 27.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class LoginViewController : AbstractLoginViewController {

    override func didSuccessfullyLogin() {
        super.didSuccessfullyLogin()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
