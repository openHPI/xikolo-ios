//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common

protocol RefreshableViewController: AnyObject {

    var refreshableScrollView: UIScrollView { get }

    func refreshingAction() -> Future<Void, XikoloError>
    func didRefresh()

}

extension RefreshableViewController {

    func addRefreshControl() {
        let refreshControl = RefreshControl(action: self.refreshingAction, postAction: self.didRefresh)
        self.refreshableScrollView.refreshControl = refreshControl
    }

    func didRefresh() {}

    func refresh() {
        self.refreshingAction().onComplete { _ in
            self.didRefresh()
        }
    }

}

extension RefreshableViewController where Self: UITableViewController {

    var refreshableScrollView: UIScrollView {
        return self.tableView
    }

}

extension RefreshableViewController where Self: UICollectionViewController {

    var refreshableScrollView: UIScrollView {
        return self.collectionView.require(hint: "UICollectionViewController must have a collectioView")
    }

}


