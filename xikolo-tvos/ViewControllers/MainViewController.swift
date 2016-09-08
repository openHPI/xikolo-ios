//
//  MainViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 23.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class MainViewController : UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameView: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureViews()
    }

    func configureViews() {
        if UserProfileHelper.isLoggedIn() {
            UserProfileHelper.getUser().onSuccess { user in
                self.displayNameView.text = user.firstName + " " + user.lastName
                if user.visual != "" {
                    if let url = NSURL(string: user.visual) {
                        ImageHelper.loadImageFromURL(url, toImageView: self.profileImageView)
                    }
                }
                self.profileImageView.hidden = false
                self.displayNameView.hidden = false
                self.settingsButton.hidden = false
                self.loginButton.hidden = true
            }
        } else {
            profileImageView.hidden = true
            displayNameView.hidden = true
            settingsButton.hidden = true
            loginButton.hidden = false
        }
    }

    @IBAction func openSettings(sender: UIButton) {
        Settings.open()
    }

    @IBAction func openLogin(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        vc.delegate = self
        self.navigationController?.presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) {
    }

}

extension MainViewController : AbstractLoginViewControllerDelegate {

    func didSuccessfullyLogin() {
        self.configureViews()
    }

}
