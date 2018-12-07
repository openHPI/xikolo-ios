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

    private lazy var showStreamingSettingsItem: Item = {
        let title = NSLocalizedString("settings.cell-title.streaming-settings", comment: "section title for streaming settings")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showStreamingSettings)
    }()

    private lazy var showDownloadSettingsItem: Item = {
        let title = NSLocalizedString("settings.cell-title.download-settings", comment: "cell title for download settings")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showDownloadSettings)
    }()

    private lazy var showDownloadedContentItem: Item = {
        let title = NSLocalizedString("settings.cell-title.downloaded-content", comment: "cell title for downloaded content")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showDownloadedContent)
    }()

    private lazy var showCertificatesItem: Item = {
        let title = NSLocalizedString("settings.cell-title.certificates", comment: "cell title for certificates")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showCertificates)
    }()

    private lazy var showImprintItem: Item = {
        let title = NSLocalizedString("settings.cell-title.imprint", comment: "cell title for imprint")
        return URLItem(title: title, url: Routes.imprint)
    }()

    private lazy var showPrivacyStatementItem: Item = {
        let title = NSLocalizedString("settings.cell-title.data-privacy", comment: "cell title for data privacy statement")
        return URLItem(title: title, url: Routes.privacy)
    }()

    private lazy var showGithubPageItem: Item = {
        let format = NSLocalizedString("settings.cell-title.github.%@ iOS app on GitHub",
                                      comment: "title for link to GitHub repo (includes application name)")
        let title = String.localizedStringWithFormat(format, UIApplication.appName)
        return URLItem(title: title, url: Routes.github)
    }()

    private lazy var sendFeedbackItem: Item = {
        let title = NSLocalizedString("settings.cell-title.app-feedback", comment: "cell title for app feedback")
        return ActionItem(title: title, cellReuseIdentifier: R.reuseIdentifier.defaultCell.identifier) { viewController in
            viewController.sendFeedbackMail()
        }
    }()

    private lazy var logoutItem: Item = {
        let title = NSLocalizedString("settings.cell-title.logout", comment: "cell title for logout")
        return ActionItem(title: title, cellReuseIdentifier: R.reuseIdentifier.logoutCell.identifier, action: { _ in
            UserProfileHelper.shared.logout()
        })
    }()

    private lazy var content = self.generateContent()

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

        self.content = self.generateContent()
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

    private func generateContent() -> [Section] {
        let settingsSectionTitle = NSLocalizedString("settings.section-title.settings", comment: "section title for settings")
        let aboutSectionTitle = NSLocalizedString("settings.section-title.about", comment: "section title for about")

        var sections = [
            Section(title: settingsSectionTitle, items: [
                self.showStreamingSettingsItem,
                self.showDownloadSettingsItem,
            ]),
        ]

        if UserProfileHelper.shared.isLoggedIn {
            sections += [
                Section(items: [
                    self.showDownloadedContentItem,
                    self.showCertificatesItem,
                ]),
            ]
        }

        sections += [
            Section(title: aboutSectionTitle, items: [
                self.showImprintItem,
                self.showPrivacyStatementItem,
                self.showGithubPageItem
            ]),
        ]

        if MFMailComposeViewController.canSendMail() {
            sections.append(Section(items: [
                self.sendFeedbackItem,
            ]))
        }

        if UserProfileHelper.shared.isLoggedIn {
            sections += [
                Section(items: [
                    self.logoutItem,
                ]),
            ]
        }

        return sections
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.content.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.content[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.content[indexPath.section].items[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellReuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.content[indexPath.section].items[indexPath.item].performAction(on: self)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.content[section].title
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

    @IBAction private func unwindToSettingsViewController(_ segue: UIStoryboardSegue) {}

}

extension AccountViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

}


import Rswift

struct Section {
    let title: String?
    let items: [Item]
}

extension Section {
    init(items: [Item]) {
        self.init(title: nil, items: items)
    }
}

protocol Item {
    var title: String { get }
    var cellReuseIdentifier: String { get }

    func configure(_ cell: UITableViewCell)
    func performAction(on viewController: AccountViewController)
}

extension Item {
    func configure(_ cell: UITableViewCell) {
        cell.textLabel?.text = self.title
    }
}

struct SegueItem<T: StoryboardSegueIdentifierType>: Item where T.SourceType == AccountViewController {
    let title: String
    let segueIdentifier: T
    let cellReuseIdentifier = R.reuseIdentifier.defaultCell.identifier

    func performAction(on viewController: AccountViewController) {
        viewController.performSegue(withIdentifier: self.segueIdentifier.identifier, sender: nil)
    }
}

struct URLItem: Item {
    let title: String
    let url: URL
    let cellReuseIdentifier = R.reuseIdentifier.defaultCell.identifier

    func performAction(on viewController: AccountViewController) {
        viewController.open(url: self.url)
    }
}

struct ActionItem: Item {
    let title: String
    let action: (AccountViewController) -> Void
    let cellReuseIdentifier = R.reuseIdentifier.defaultCell.identifier

    func configure(_ cell: UITableViewCell) {}
    func performAction(on viewController: AccountViewController) {
        self.action(viewController)
    }
}
