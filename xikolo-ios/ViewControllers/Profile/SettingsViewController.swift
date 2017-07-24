//
//  SettingsViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import SDWebImage

class SettingsViewController: UITableViewController {

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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingsViewController.updateUIAfterLoginLogoutAction),
                                               name: NotificationKeys.loginStateChangedKey,
                                               object: nil)
    }

    func updateUIAfterLoginLogoutAction() {
        if UserProfileHelper.isLoggedIn() {
            self.navigationItem.rightBarButtonItem =  nil
            nameView.isHidden = false
            emailView.isHidden = false
            logoutButton.isHidden = false
            UserHelper.syncMe().onSuccess(callback: { _ in self.updateProfileInfo() })
            updateProfileInfo()
        } else {
            self.navigationItem.rightBarButtonItem = self.loginButton
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
        NotificationCenter.default.removeObserver(self)
    }

}
