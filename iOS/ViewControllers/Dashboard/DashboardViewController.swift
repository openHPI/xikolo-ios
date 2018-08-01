//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class DashboardViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 250

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        self.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackingHelper.shared.createEvent(.visitedDashboard)
    }

    @objc func refresh() {
        let deadline = UIRefreshControl.minimumSpinningTime.fromNow
        let stopRefreshControl = {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.tableView.refreshControl?.endRefreshing()
            }
        }

        CourseHelper.syncAllCourses().onComplete { _ in
            CourseDateHelper.syncAllCourseDates().onComplete { _ in
                stopRefreshControl()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.courseDateOverviewCell, for: indexPath).require()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.courseOverviewCell, for: indexPath).require()
            let configuration: CourseOverviewCell.Configuration = indexPath.section == 1 ? .currentCourses : .completedCourses
            cell.configure(for: configuration)
            return cell
        }
    }

}
