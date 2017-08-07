//
//  SettingsViewController.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import SafariServices
import SDWebImage

class SettingsViewController: UITableViewController {

    static let logoutIndexPath = IndexPath(row: 0, section: 2)

    @IBOutlet var loginButton: UIBarButtonItem!

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameView: UILabel!
    @IBOutlet weak var emailView: UILabel!

    @IBOutlet weak var preloadContentSwitch: UISwitch!

    @IBOutlet weak var versionView: UILabel!
    @IBOutlet weak var buildView: UILabel!

    var user: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()

        // set preload content settings
        let contentPreloadDeactivated = UserDefaults.standard.bool(forKey: UserDefaultsKeys.noContentPreloadKey)
        self.preloadContentSwitch.setOn(!contentPreloadDeactivated, animated: false)

        // set app version info
        self.versionView.text = NSLocalizedString("Version", comment: "app version") + ": " + UIApplication.appVersion()
        self.buildView.text = NSLocalizedString("Build", comment: "app version") + ": " + UIApplication.appBuild()

        self.updateUIAfterLoginStateChanged()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingsViewController.updateUIAfterLoginStateChanged),
                                               name: NotificationKeys.loginStateChangedKey,
                                               object: nil)
    }

    func updateUIAfterLoginStateChanged() {
        if UserProfileHelper.isLoggedIn() {
            self.navigationItem.rightBarButtonItem = nil
            self.updateProfileInfo()

            self.profileImage.isHidden = false
            self.nameView.isHidden = false
            self.emailView.isHidden = false

            UserHelper.syncMe().onSuccess(callback: { _ in self.updateProfileInfo() })
        } else {
            self.navigationItem.rightBarButtonItem = self.loginButton

            self.profileImage.isHidden = true
            self.nameView.isHidden = true
            self.emailView.isHidden = true
        }


        self.tableView.reloadData()
    }

    func updateProfileInfo() {
        guard let user = try! UserHelper.getMe() else { return }
        let userProfile = user.profile!
        self.emailView.text = userProfile.email
        self.nameView.text = (userProfile.first_name ?? "") + " " + (userProfile.last_name ?? "")
        self.profileImage.sd_setImage(with: user.avatar_url)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.item) {
        case (0, 0):
            if let url = URL(string: Brand.APP_IMPRINT_URL) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
                safariVC.preferredControlTintColor = Brand.TintColor
            }
        case (0, 1):
            if let url = URL(string: Brand.APP_PRIVACY_URL) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
                safariVC.preferredControlTintColor = Brand.TintColor
            }
        case (SettingsViewController.logoutIndexPath.section, SettingsViewController.logoutIndexPath.row):
            UserProfileHelper.logout()
        default:
            break
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = super.numberOfSections(in: tableView)
        return UserProfileHelper.isLoggedIn() ? numberOfSections : numberOfSections - 1
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Dynamic sizing for the header view
        if let headerView = self.tableView.tableHeaderView {
            let height: CGFloat = UserProfileHelper.isLoggedIn() ? 260 : 190
            var headerFrame = headerView.frame

            // Don't set the same height again to prevent a infinte loop hang.
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                self.tableView.tableHeaderView = headerView
            }
        }
    }

    @IBAction func preloadContentSettingChanged(_ sender: UISwitch) {
        let contentPreloadDeactivated = !sender.isOn
        UserDefaults.standard.set(contentPreloadDeactivated, forKey: UserDefaultsKeys.noContentPreloadKey)
        UserDefaults.standard.synchronize()
    }
}
