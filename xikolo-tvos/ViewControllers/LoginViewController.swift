//
//  LoginViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 27.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class LoginViewController : AbstractLoginViewController {

    override func viewDidLoad() {
        self.delegate = self
        super.viewDidLoad()
    }

}

extension LoginViewController : AbstractLoginViewControllerDelegate {

    func didSuccessfullyLogin() {
        //TODO: Actually do something.
    }

}
