//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import MessageUI
import Result
import SafariServices
import SDWebImage
import UIKit

class AccountViewController: UITableViewController {

    static let feedbackIndexPath = IndexPath(row: 0, section: 2)
    static let logoutIndexPath = IndexPath(row: 0, section: 3)

    @IBOutlet private weak var videoSettingsCell: UITableViewCell!
    @IBOutlet private weak var downloadCell: UITableViewCell!
    @IBOutlet private weak var imprintCell: UITableViewCell!
    @IBOutlet private weak var dataPrivacyCell: UITableViewCell!
    @IBOutlet private weak var githubCell: UITableViewCell!

    @IBOutlet private var loginButton: UIBarButtonItem!

    @IBOutlet private weak var headerImage: UIImageView!
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var nameView: UILabel!
    @IBOutlet private weak var emailView: UILabel!

    @IBOutlet private weak var copyrightLabel: UILabel!
    @IBOutlet private weak var poweredByLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var buildLabel: UILabel!

    private var userObserver: ManagedObjectObserver?

    var user: User? {
        didSet {
            if let user = self.user {
                self.userObserver = ManagedObjectObserver(object: user) { [weak self] type in
                    guard type == .update else { return }
                    DispatchQueue.main.async {
                        self?.updateProfileInfo()
                    }
                }
            } else {
                self.userObserver = nil
            }

            if self.user != oldValue {
                DispatchQueue.main.async {
                    self.updateProfileInfo()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateUIAfterLoginStateChanged()

        // set text for github link
        let localizedGithubText = NSLocalizedString("settings.github-link.%@ iOS app on GitHub",
                                                    comment: "title for link to GitHub repo (includes application name)")
        self.githubCell.textLabel?.text = String.localizedStringWithFormat(localizedGithubText, UIApplication.appName)

        // set copyright and app version info
        self.copyrightLabel.text = Brand.default.copyrightText
        self.poweredByLabel.text = Brand.default.poweredByText
        self.poweredByLabel.isHidden = Brand.default.poweredByText == nil
        self.versionLabel.text = NSLocalizedString("settings.app.version.label", comment: "label for app version") + ": " + UIApplication.appVersion
        self.buildLabel.text = NSLocalizedString("settings.app.build.label", comment: "label for app build") + ": " + UIApplication.appBuild

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUIAfterLoginStateChanged),
                                               name: UserProfileHelper.loginStateDidChangeNotification,
                                               object: nil)
    }

    @objc func updateUIAfterLoginStateChanged() {
        if UserProfileHelper.shared.isLoggedIn {
            self.navigationItem.rightBarButtonItem = nil

            CoreDataHelper.viewContext.perform {
                if let userId = UserProfileHelper.shared.userId {
                    let fetchRequest = UserHelper.FetchRequest.user(withId: userId)
                    if let user = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value {
                        self.user = user
                    }
                }

                UserHelper.syncMe().onSuccess { syncResult in
                    guard let user = CoreDataHelper.viewContext.existingTypedObject(with: syncResult.objectId) as? User else {
                        log.warning("Failed to retrieve user to display")
                        return
                    }

                    self.user = user
                }
            }
        } else {
            self.navigationItem.rightBarButtonItem = self.loginButton
            self.user = nil
        }

        self.tableView.reloadData()
    }

    func updateProfileInfo() {
        let profileViews: [UIView] = [self.profileImage, self.nameView, self.emailView]

        if let userProfile = self.user?.profile {
            self.profileImage.sd_setImage(with: self.user?.avatarURL, placeholderImage: R.image.avatar())
            self.nameView.text = userProfile.fullName
            self.emailView.text = userProfile.email

            for view in profileViews {
                view.alpha = 0
                view.isHidden = false
            }

            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                UIView.animate(withDuration: 0.25) {
                    for view in profileViews {
                        view.alpha = 1
                    }
                }
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                for view in profileViews {
                    view.alpha = 0
                }
            }, completion: { _ in
                for view in profileViews {
                    view.isHidden = true
                }

                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            })
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newIndexPath = self.indexPathIncludingHiddenCells(for: indexPath)
        switch newIndexPath {
        case let videoStreamingIndexPath where videoStreamingIndexPath == tableView.indexPath(for: self.videoSettingsCell):
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: R.segue.accountViewController.modalStreamingSettings, sender: self)
                self.tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
            } else {
                self.performSegue(withIdentifier: R.segue.accountViewController.pushStreamingSettings, sender: self)
            }
        case let downloadIndexPath where downloadIndexPath == tableView.indexPath(for: self.downloadCell):
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: R.segue.accountViewController.modalDownloadSettings, sender: self)
                self.tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
            } else {
                self.performSegue(withIdentifier: R.segue.accountViewController.pushDownloadSettings, sender: self)
            }
        case let imprintIndexPath where imprintIndexPath == tableView.indexPath(for: self.imprintCell):
            self.open(url: Routes.imprint)
        case let dataPrivacyIndexPath where dataPrivacyIndexPath == tableView.indexPath(for: self.dataPrivacyCell):
            self.open(url: Routes.privacy)
        case let githubIndexPath where githubIndexPath == tableView.indexPath(for: self.githubCell):
            self.open(url: Routes.github)
        case AccountViewController.feedbackIndexPath:
            self.sendFeedbackMail()
        case AccountViewController.logoutIndexPath:
            UserProfileHelper.shared.logout()
        default:
            break
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = super.numberOfSections(in: tableView)

        if !MFMailComposeViewController.canSendMail() {
            numberOfSections -= 1
        }

        if !UserProfileHelper.shared.isLoggedIn {
            numberOfSections -= 1
        }

        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return super.tableView(tableView, cellForRowAt: self.indexPathIncludingHiddenCells(for: indexPath))
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let headerView = self.tableView.tableHeaderView {
            let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if headerView.frame.size.height != size.height {
                headerView.frame.size.height = size.height
                self.tableView.tableHeaderView = headerView
                self.tableView.layoutIfNeeded()
            }
        }

        if let footerView = self.tableView.tableFooterView {
            let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if footerView.frame.size.height != size.height {
                footerView.frame.size.height = size.height
                self.tableView.tableFooterView = footerView
                self.tableView.layoutIfNeeded()
            }
        }
    }

    private func indexPathIncludingHiddenCells(for indexPath: IndexPath) -> IndexPath {
        var newIndexPath = indexPath

        if !MFMailComposeViewController.canSendMail(), indexPath.section >= AccountViewController.feedbackIndexPath.section {
            newIndexPath.section += 1
        }

        if !UserProfileHelper.shared.isLoggedIn, indexPath.section >= AccountViewController.logoutIndexPath.section {
            newIndexPath.section += 1
        }

        return newIndexPath
    }

    private func open(url: URL?) {
        guard let urlToOpen = url else { return }

        let safariVC = SFSafariViewController(url: urlToOpen)
        safariVC.preferredControlTintColor = Brand.default.colors.window
        self.present(safariVC, animated: trueUnlessReduceMotionEnabled)
    }

    private func sendFeedbackMail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(Brand.default.feedbackRecipients)
        composeVC.setSubject(Brand.default.feedbackSubject)
        composeVC.setMessageBody(self.feedbackMailSystemInfo, isHTML: true)
        composeVC.navigationBar.tintColor = Brand.default.colors.window
        self.present(composeVC, animated: trueUnlessReduceMotionEnabled)
    }

    private var feedbackMailSystemInfo: String {
        let components = [
            "<b>System info</b>",
            "platform: \(UIApplication.platform)",
            "os version: \(UIApplication.osVersion)",
            "device: \(UIApplication.device)",
            "app name: \(UIApplication.appName)",
            "app version: \(UIApplication.appVersion)",
            "app build: \(UIApplication.appBuild)",
        ]
        return "<br/><br/><small>" + components.joined(separator: "<br/>") + "</small>"
    }

    @IBAction private func unwindToSettingsViewController(_ segue: UIStoryboardSegue) { }

}

extension AccountViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

}
