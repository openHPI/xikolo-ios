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

    @IBOutlet private weak var copyrightLabel: UILabel!
    @IBOutlet private weak var poweredByLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var buildLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self.dataSource

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
        } else {
            self.navigationItem.rightBarButtonItem = self.loginButton
        }

        self.dataSource.reloadContent()
        self.tableView.reloadData() // TODO: explicit animation

        if UserProfileHelper.shared.isLoggedIn {
            UserHelper.syncMe().onComplete { [weak self] _ in
                let indexPath = IndexPath(row: 0, section: 0)
                let userProfileCell = self?.tableView.cellForRow(at: indexPath) as? UserProfileCell
                userProfileCell?.loadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dataSource.item(for: indexPath).performAction(on: self)
        tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.navigationController?.navigationBar.sizeToFit()
            self.tableView.resizeTableHeaderView()
            self.tableView.resizeTableFooterView()
        }
    }

    func open(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = Brand.default.colors.window
        self.present(safariVC, animated: trueUnlessReduceMotionEnabled)
    }

}

extension AccountViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

}
