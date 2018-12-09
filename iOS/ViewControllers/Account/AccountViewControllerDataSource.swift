//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import MessageUI
import Rswift
import UIKit

class AccountViewControllerDataSource: NSObject {

    private lazy var showStreamingSettingsItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.streaming-settings", comment: "section title for streaming settings")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showStreamingSettings)
    }()

    private lazy var showDownloadSettingsItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.download-settings", comment: "cell title for download settings")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showDownloadSettings)
    }()

    private lazy var showDownloadedContentItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.downloaded-content", comment: "cell title for downloaded content")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showDownloadedContent)
    }()

    private lazy var showCertificatesItem: DataSourceItem = {
        let title = NSLocalizedString("settings.cell-title.certificates", comment: "cell title for certificates")
        return SegueItem(title: title, segueIdentifier: R.segue.accountViewController.showCertificates)
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
        let title = NSLocalizedString("settings.cell-title.app-feedback", comment: "cell title for app feedback")
        return ActionItem(title: title) { viewController in
            viewController.sendFeedbackMail()
        }
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

        var sections = [
            DataSourceSection(title: settingsSectionTitle, items: [
                self.showStreamingSettingsItem,
                self.showDownloadSettingsItem,
            ]),
        ]

        if UserProfileHelper.shared.isLoggedIn {
            sections += [
                DataSourceSection(items: [
                    self.showDownloadedContentItem,
                    self.showCertificatesItem,
                ]),
            ]
        }

        sections += [
            DataSourceSection(title: aboutSectionTitle, items: [
                self.showImprintItem,
                self.showPrivacyStatementItem,
                self.showGithubPageItem,
            ]),
        ]

        if MFMailComposeViewController.canSendMail() {
            sections.append(DataSourceSection(items: [
                self.sendFeedbackItem,
            ]))
        }

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

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.content[section].title
    }

}

// swiftlint:disable:next private_over_fileprivate
fileprivate struct DataSourceSection {
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
    var title: String { get }
    func configure(_ cell: UITableViewCell)
}

extension ConfigurableDataSourceItem {
    fileprivate func configure(_ cell: UITableViewCell) {
        cell.textLabel?.text = self.title
    }
}

// swiftlint:disable:next private_over_fileprivate
fileprivate struct SegueItem<T: StoryboardSegueIdentifierType>: ConfigurableDataSourceItem where T.SourceType == AccountViewController {
    let title: String
    let segueIdentifier: T
    let cellReuseIdentifier = R.reuseIdentifier.defaultCell.identifier

    func performAction(on viewController: AccountViewController) {
        viewController.performSegue(withIdentifier: self.segueIdentifier.identifier, sender: nil)
    }
}

// swiftlint:disable:next private_over_fileprivate
fileprivate struct URLItem: ConfigurableDataSourceItem {
    let title: String
    let url: URL
    let cellReuseIdentifier = R.reuseIdentifier.defaultCell.identifier

    func performAction(on viewController: AccountViewController) {
        viewController.open(url: self.url)
    }
}

// swiftlint:disable:next private_over_fileprivate
fileprivate struct ActionItem: ConfigurableDataSourceItem {
    let cellReuseIdentifier = R.reuseIdentifier.defaultCell.identifier
    let title: String
    let action: (AccountViewController) -> Void

    func performAction(on viewController: AccountViewController) {
        self.action(viewController)
    }
}

// swiftlint:disable:next private_over_fileprivate
fileprivate struct LogoutItem: DataSourceItem {
    let cellReuseIdentifier = R.reuseIdentifier.logoutCell.identifier
    let action: (AccountViewController) -> Void

    func performAction(on viewController: AccountViewController) {
        self.action(viewController)
    }
}
