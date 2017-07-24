//
//  SettingsViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import SDWebImage

class SettingsViewController: UITableViewController, LoginButtonViewController {

    @IBOutlet var loginButton: UIBarButtonItem!

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var nameView: UILabel!
    @IBOutlet weak var emailView: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var versionView: UILabel!
    @IBOutlet weak var buildView: UILabel!

    @IBAction func logout(_ sender: UIButton) {
        UserProfileHelper.logout()
    }

    var user: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()
        versionView.text = NSLocalizedString("Version", comment: "app version") + ": " + UIApplication.appVersion()
        buildView.text = NSLocalizedString("Build", comment: "app version") + ": " + UIApplication.appBuild()

        self.addLoginObserver(with: #selector(SettingsViewController.updateUIAfterLoginLogoutAction))
    }

    func updateUIAfterLoginLogoutAction() {
        self.updateLoginButton()

        if UserProfileHelper.isLoggedIn() {
            nameView.isHidden = false
            emailView.isHidden = false
            logoutButton.isHidden = false
            UserHelper.syncMe().onSuccess(callback: { _ in self.updateProfileInfo() })
            updateProfileInfo()
        } else {
            nameView.isHidden = true
            emailView.isHidden = true
            logoutButton.isHidden = true
        }
    }

    func updateProfileInfo() {
        guard let user = try! UserHelper.getMe() else { return }
        let userProfile = user.profile!
        self.emailView.text = userProfile.email
        self.nameView.text = (userProfile.first_name ?? "") + " " + (userProfile.last_name ?? "")
        self.profileImage.sd_setImage(with: user.avatar_url)
    }

    deinit {
        self.removeLoginObserver()
    }

}
