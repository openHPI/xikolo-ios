//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

class MoreViewController: CustomWidthViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var newsLabel: UILabel!
    @IBOutlet private weak var additionalMaterialsContainerHeight: NSLayoutConstraint!
    @IBOutlet private weak var announcementsContainerHeight: NSLayoutConstraint!

    private lazy var actionButton: UIBarButtonItem = {
        let markAllAsReadActionTitle = NSLocalizedString("announcement.alert.mark all as read",
                                                         comment: "alert action title to mark all announcements as read")
        let markAllAsReadAction = Action(title: markAllAsReadActionTitle, image: Action.Image.markAsRead) {
            AnnouncementHelper.markAllAsVisited()
        }

        let item = UIBarButtonItem.circularItem(
            with: R.image.navigationBarIcons.dots(),
            target: self,
            menuActions: [[markAllAsReadAction]]
        )

        item.accessibilityLabel = NSLocalizedString(
            "accessibility-label.announcements.navigation-bar.item.actions",
            comment: "Accessibility label for actions button in navigation bar of the course card view"
        )

        return item
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11, *) {
            let font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
            self.newsLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: font)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUIAfterLoginStateChanged),
                                               name: UserProfileHelper.loginStateDidChangeNotification,
                                               object: nil)

        self.updateUIAfterLoginStateChanged()

        self.addRefreshControl()
        self.refresh()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableViewController = segue.destination as? UITableViewController {
            tableViewController.tableView.isScrollEnabled = false
        } else if let collectionViewController = segue.destination as? UICollectionViewController {
            collectionViewController.collectionView.isScrollEnabled = false
        }
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container is AdditionalLearningMaterialListViewController {
            self.additionalMaterialsContainerHeight?.constant = container.preferredContentSize.height
        } else if container is AnnouncementListViewController {
            self.announcementsContainerHeight?.constant = container.preferredContentSize.height
        }
    }

    @objc private func updateUIAfterLoginStateChanged() {
        self.navigationItem.rightBarButtonItem = UserProfileHelper.shared.isLoggedIn ? self.actionButton : nil
    }

}

extension MoreViewController: RefreshableViewController {

    var refreshableScrollView: UIScrollView {
        return self.scrollView
    }

    func refreshingAction() -> Future<Void, XikoloError> {
        return AnnouncementHelper.syncAllAnnouncements().asVoid()
    }

}
