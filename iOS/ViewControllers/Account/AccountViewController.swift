//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import MessageUI
import SafariServices
import UIKit

class AccountViewController: UITableViewController {

    private lazy var dataSource = AccountViewControllerDataSource()
    private lazy var shouldSynchronizeUser = false

    @IBOutlet private weak var copyrightLabel: UILabel!
    @IBOutlet private weak var poweredByLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var buildLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self.dataSource
        self.navigationController?.delegate = self

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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dataSource.item(for: indexPath).performAction(on: self)
        tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.navigationController?.navigationBar.sizeToFit()
            self.tableView.resizeTableFooterView()
        }
    }

    func open(url: URL, inApp: Bool = false) {
        if inApp {
            let webViewController = R.storyboard.webViewController.instantiateInitialViewController().require()
            webViewController.url = url
            self.navigationController?.pushViewController(webViewController, animated: trueUnlessReduceMotionEnabled)
            self.shouldSynchronizeUser = true
        } else {
            let safariVC = SFSafariViewController(url: url)
            safariVC.preferredControlTintColor = Brand.default.colors.window
            self.present(safariVC, animated: trueUnlessReduceMotionEnabled)
        }
    }

    @objc private func updateUIAfterLoginStateChanged() {
        self.dataSource.reloadContent()
        self.tableView.reloadData()
        self.synchronizeUser()
    }

    private func synchronizeUser() {
        if UserProfileHelper.shared.isLoggedIn {
            UserHelper.syncMe().onComplete { [weak self] _ in
                let indexPath = IndexPath(row: 0, section: 0)
                let userProfileCell = self?.tableView.cellForRow(at: indexPath) as? UserProfileCell
                userProfileCell?.loadData()
            }
        }
    }

}

extension AccountViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController == self else { return }
        guard self.shouldSynchronizeUser else { return }
        self.shouldSynchronizeUser = false
        self.synchronizeUser()
    }

}
