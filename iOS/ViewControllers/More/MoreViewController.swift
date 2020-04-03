//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

class MoreViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var newsLabel: UILabel!
    @IBOutlet private weak var additonalMaterialsContainerHeight: NSLayoutConstraint!
    @IBOutlet private weak var announcementsContainerHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11, *) {
            let font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
            self.newsLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: font)
        }

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
            self.additonalMaterialsContainerHeight?.constant = container.preferredContentSize.height
        } else if container is AnnouncementListViewController {
            self.announcementsContainerHeight?.constant = container.preferredContentSize.height
        }
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
