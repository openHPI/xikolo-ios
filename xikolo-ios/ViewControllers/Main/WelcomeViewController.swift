//
//  WelcomeViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 13.05.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBAction func dismissAction(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
