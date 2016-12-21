//
//  ProfileViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class ProfileViewController: AbstractTabContentViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var nameView: UILabel!
    @IBOutlet weak var emailView: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var logoutButton: UIButton!

    @IBAction func logout(sender: UIButton) {
        UserProfileHelper.logout()
    }

    var user: UserProfile?

    override func updateUIAfterLoginLogoutAction() {
        super.updateUIAfterLoginLogoutAction()

        if UserProfileHelper.isLoggedIn() {
            nameView.hidden = false
            emailView.hidden = false
            logoutButton.hidden = false

            UserProfileHelper.getUser().onSuccess { user in
                self.nameView.text = user.firstName + " " + user.lastName
                self.emailView.text = user.email
                if let url = NSURL(string: user.visual) {
                    ImageHelper.loadImageFromURL(url, toImageView: self.profileImage)
                }
            }
        } else {
            nameView.hidden = true
            emailView.hidden = true
            logoutButton.hidden = true
            profileImage.image = UIImage(named: "avatar")
        }
    }

}
