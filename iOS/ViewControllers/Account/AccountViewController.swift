//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import MessageUI
import SafariServices
import SDWebImage
import UIKit

class AccountViewController: UITableViewController {

    private lazy var dataSource = AccountViewControllerDataSource()

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

        self.tableView.dataSource = self.dataSource

        self.updateUIAfterLoginStateChanged()

        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        self.profileImage.layer.borderWidth = 3.0

        self.traitCollection.performAsCurrent {
             self.profileImage.layer.borderColor = ColorCompatibility.systemBackground.cgColor
        }

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

        self.dataSource.reloadContent()
        self.tableView.reloadData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.profileImage.layer.borderColor = ColorCompatibility.systemBackground.cgColor
            }
        }
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
        self.dataSource.item(for: indexPath).performAction(on: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.resizeTableHeaderView()
        self.tableView.resizeTableFooterView()
    }

    func open(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = Brand.default.colors.window
        self.present(safariVC, animated: trueUnlessReduceMotionEnabled)
    }

    func sendFeedbackMail() {
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

}

extension AccountViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

}
