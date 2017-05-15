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
                    self.profileImageView.sd_setImage(with: URL(string: user.visual))
                }
                self.profileImageView.isHidden = false
                self.displayNameView.isHidden = false
                self.settingsButton.isHidden = false
                self.loginButton.isHidden = true
            }
        } else {
            profileImageView.isHidden = true
            displayNameView.isHidden = true
            settingsButton.isHidden = true
            loginButton.isHidden = false
        }
    }

    @IBAction func openSettings(_ sender: UIButton) {
        Settings.open()
    }

    @IBAction func openLogin(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc.delegate = self
        self.navigationController?.present(vc, animated: true, completion: nil)
    }

    @IBAction func unwindToMainViewController(_ segue: UIStoryboardSegue) {
    }

}

extension MainViewController : AbstractLoginViewControllerDelegate {

    func didSuccessfullyLogin() {
        self.configureViews()
    }

}
