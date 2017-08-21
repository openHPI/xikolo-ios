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
import MessageUI

class SettingsViewController: UITableViewController {

    static let feedbackIndexPath = IndexPath(row: 0, section: 2)
    static let logoutIndexPath = IndexPath(row: 0, section: 3)

    @IBOutlet weak var imprintCell: UITableViewCell!
    @IBOutlet weak var dataPrivacyCell: UITableViewCell!
    @IBOutlet weak var githubCell: UITableViewCell!

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

        // set text for github link
        let localizedGithubText = NSLocalizedString("%@ iOS app on GitHub", comment: "text for link to GitHub repo incl. app name")
        self.githubCell.textLabel?.text = String.localizedStringWithFormat(localizedGithubText, UIApplication.appName)

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
        let newIndexPath = self.indexPathIncludingHiddenCells(for: indexPath)
        switch newIndexPath {
        case let imprintIndexPath where imprintIndexPath == tableView.indexPath(for: self.imprintCell):
            self.open(url: URL(string: Brand.APP_IMPRINT_URL))
        case let dataPrivacyIndexPath where dataPrivacyIndexPath == tableView.indexPath(for: self.dataPrivacyCell):
            self.open(url: URL(string: Brand.APP_PRIVACY_URL))
        case let githubIndexPath where githubIndexPath == tableView.indexPath(for: self.githubCell):
            self.open(url: URL(string: Brand.APP_GITHUB_URL))
        case SettingsViewController.feedbackIndexPath:
            self.sendFeedbackMail()
        case SettingsViewController.logoutIndexPath:
            UserProfileHelper.logout()
        default:
            break
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = super.numberOfSections(in: tableView)

        if !MFMailComposeViewController.canSendMail() {
            numberOfSections -= 1
        }

        if !UserProfileHelper.isLoggedIn() {
            numberOfSections -= 1
        }

        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return super.tableView(tableView, cellForRowAt: self.indexPathIncludingHiddenCells(for: indexPath))
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

    private func indexPathIncludingHiddenCells(for indexPath: IndexPath) -> IndexPath {
        var newIndexPath = indexPath

        if !MFMailComposeViewController.canSendMail(), indexPath.section >= SettingsViewController.feedbackIndexPath.section {
            newIndexPath.section += 1
        }

        if !UserProfileHelper.isLoggedIn(), indexPath.section >= SettingsViewController.logoutIndexPath.section {
            newIndexPath.section += 1
        }

        return newIndexPath
    }

    private func open(url: URL?) {
        guard let urlToOpen = url else { return }

        let safariVC = SFSafariViewController(url: urlToOpen)
        safariVC.preferredControlTintColor = Brand.TintColor
        self.present(safariVC, animated: true, completion: nil)
    }

    private func sendFeedbackMail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(Brand.FeedbackRecipients)
        composeVC.setSubject(Brand.FeedbackSubject)
        composeVC.setMessageBody(self.feedbackMailSystemInfo, isHTML: false)
        composeVC.navigationBar.tintColor = Brand.TintColor
        self.present(composeVC, animated: true, completion: nil)
    }

    private var feedbackMailSystemInfo: String {
        let components = [
            "",
            "",
            "---------------------",
            "System info",
            "---------------------",
            "platform: \(UIApplication.platform)",
            "os version: \(UIApplication.osVersion)",
            "device: \(UIApplication.device)",
            "app name: \(UIApplication.appName)",
            "app version: \(UIApplication.appVersion())",
            "app build: \(UIApplication.appBuild())",

        ]
        return components.joined(separator: "\n")
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
