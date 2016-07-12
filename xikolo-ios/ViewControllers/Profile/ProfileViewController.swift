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

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var logoutButton: UIButton!

    @IBAction func logout(sender: UIButton) {
        UserProfileHelper.logout()
    }

    override func updateUIAfterLoginLogoutAction() {
        super.updateUIAfterLoginLogoutAction()

        if UserProfileHelper.isLoggedIn() {
            container.hidden = false
            logoutButton.hidden = false

            UserProfileHelper.getUser() { user, error -> () in
                if let user = user {
                    // TODO: get name, username etc.
                    ImageHelper.loadImageFromURL(user.visual, toImageView: self.profileImage)
                }
                // TODO: Error handling.
            }
        } else {
            container.hidden = true
            logoutButton.hidden = true
            profileImage.image = UIImage(named: "avatar")
        }
    }

}
