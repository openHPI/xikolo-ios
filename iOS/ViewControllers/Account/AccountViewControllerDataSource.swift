//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import MessageUI
import Rswift
import UIKit

class AccountViewControllerDataSource: NSObject {

    private lazy var loginItem: DataSourceItem = LoginItem()
    private lazy var showUserProfile: DataSourceItem = UserProfileItem()

    private lazy var showStreamingSettingsItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.streaming-settings", comment: "section title for streaming settings")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showStreamingSettings)
    }()

    private lazy var showDownloadSettingsItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.download-settings", comment: "cell title for download settings")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showDownloadSettings)
    }()

    private lazy var showAppearanceSettingsItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.appearance", comment: "cell title for appearance settings")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showAppearanceSettings)
    }()

    private lazy var showDownloadedContentItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.downloaded-content", comment: "cell title for downloaded content")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showDownloadedContent)
    }()

    private lazy var showCertificatesItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.certificates", comment: "cell title for certificates")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showCertificates)
    }()

    private lazy var showFAQItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.faq", comment: "cell title for FAQs")
        return URLItem(title: title, url: Routes.faq)
    }()

    private lazy var showImprintItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.imprint", comment: "cell title for imprint")
        return URLItem(title: title, url: Routes.imprint)
    }()

    private lazy var showPrivacyStatementItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.data-privacy", comment: "cell title for data privacy statement")
        return URLItem(title: title, url: Routes.privacy)
    }()

    private lazy var showGithubPageItem: DataSourceItem = {
        let format = NSLocalizedString("settings.cell-title.github.%@ iOS app on GitHub",
                                       comment: "title for link to GitHub repo (includes application name)")
        let title = String.localizedStringWithFormat(format, UIApplication.appName)
        return URLItem(title: title, url: Routes.github)
    }()

    private lazy var sendFeedbackItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.app-helpdesk", comment: "cell title for helpdesk")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.sendFeedback)
    }()

    private lazy var logoutItem: DataSourceItem = {
        return LogoutItem { _ in
            UserProfileHelper.shared.logout()
        }
    }()

    private lazy var content = self.generateContent()

    private func generateContent() -> [DataSourceSection] {
        let settingsSectionTitle = NSLocalizedString("settings.section-title.settings", comment: "section title for settings")
        let aboutSectionTitle = NSLocalizedString("settings.section-title.about", comment: "section title for about")

        var sections: [DataSourceSection] = []

        if UserProfileHelper.shared.isLoggedIn {
            sections += [
                DataSourceSection(items: [
                    self.showUserProfile,
                    self.showCertificatesItem,
                    self.showDownloadedContentItem,
                ]),
            ]
        } else {
            sections += [
                DataSourceSection(items: [
                    self.loginItem,
                ]),
            ]
        }

        var settings = [
            self.showStreamingSettingsItem,
            self.showDownloadSettingsItem,
        ]

        if #available(iOS 13, *) {
            settings += [self.showAppearanceSettingsItem]
        }

        sections += [
            DataSourceSection(title: settingsSectionTitle, items: settings),
        ]

        sections += [
            DataSourceSection(title: aboutSectionTitle, items: [
                self.showFAQItem,
                self.showImprintItem,
                self.showPrivacyStatementItem,
                self.showGithubPageItem,
            ]),
        ]

        sections.append(DataSourceSection(items: [
            self.sendFeedbackItem,
        ]))

        if UserProfileHelper.shared.isLoggedIn {
            sections += [
                DataSourceSection(items: [
                    self.logoutItem,
                ]),
            ]
        }

        return sections
    }

    func item(for indexPath: IndexPath) -> DataSourceItem {
        return self.content[indexPath.section].items[indexPath.item]
    }

    func reloadContent() {
        self.content = self.generateContent()
    }

}

extension AccountViewControllerDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.content.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.content[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.content[indexPath.section].items[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellReuseIdentifier, for: indexPath)

        if let configurableItem = item as? ConfigurableDataSourceItem {
            configurableItem.configure(cell)
        }

        if let userProfileCell = cell as? UserProfileCell {
            userProfileCell.tableView = tableView
        }

        cell.addDefaultPointerInteraction()

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.content[section].title
    }

}

private struct DataSourceSection {
    let title: String?
    let items: [DataSourceItem]
}

extension DataSourceSection {
    init(items: [DataSourceItem]) {
        self.init(title: nil, items: items)
    }
}

protocol DataSourceItem {
    var cellReuseIdentifier: String { get }

    func performAction(on viewController: AccountViewController)
}

protocol ConfigurableDataSourceItem: DataSourceItem {
    func configure(_ cell: UITableViewCell)
}

protocol TitledDataSourceItem: ConfigurableDataSourceItem {
    var title: String { get }
}

extension TitledDataSourceItem {
    func configure(_ cell: UITableViewCell) {
        cell.textLabel?.text = self.title
    }
}

private struct SegueItem<T: StoryboardSegueIdentifierType>: TitledDataSourceItem where T.SourceType == AccountViewController {
    let title: String
    let segueIdentifier: T
    let cellReuseIdentifier = R.reuseIdentifier.defaultCell.identifier

    func performAction(on viewController: AccountViewController) {
        viewController.performSegue(withIdentifier: self.segueIdentifier.identifier, sender: nil)
    }
}

private struct URLItem: TitledDataSourceItem {
    let title: String
    let url: URL
    let cellReuseIdentifier = R.reuseIdentifier.defaultCell.identifier

    func performAction(on viewController: AccountViewController) {
        viewController.open(url: self.url)
    }
}

private struct ActionItem: TitledDataSourceItem {
    let cellReuseIdentifier = R.reuseIdentifier.defaultCell.identifier
    let title: String
    let action: (AccountViewController) -> Void

    func performAction(on viewController: AccountViewController) {
        self.action(viewController)
    }
}

private struct LoginItem: DataSourceItem {
    let cellReuseIdentifier = R.reuseIdentifier.loginCell.identifier

    func performAction(on viewController: AccountViewController) {
        let loginNavigationController = LoginHelper.loginNavigationViewController(loginDelegate: nil)
        viewController.present(loginNavigationController, animated: trueUnlessReduceMotionEnabled)
    }
}

private struct UserProfileItem: ConfigurableDataSourceItem {
    let cellReuseIdentifier = R.reuseIdentifier.userProfileCell.identifier

    func configure(_ cell: UITableViewCell) {
        guard let userProfileCell = cell as? UserProfileCell else { return }
        userProfileCell.loadData()
    }

    func performAction(on viewController: AccountViewController) {
        viewController.open(url: Routes.profile, inApp: true)
    }
}

private struct LogoutItem: DataSourceItem {
    let cellReuseIdentifier = R.reuseIdentifier.logoutCell.identifier
    let action: (AccountViewController) -> Void

    func performAction(on viewController: AccountViewController) {
        self.action(viewController)
    }
}
