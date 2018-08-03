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
                if Brand.default.features.showCourseDatesOnDashboard {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Brand.default.features.showCourseDatesOnDashboard ? 3 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Brand.default.features.showCourseDatesOnDashboard ? indexPath.section : indexPath.section + 1
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.courseDateOverviewCell, for: indexPath).require()
            cell.loadData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.courseOverviewCell, for: indexPath).require()
            let configuration: CourseOverviewCell.Configuration = section == 1 ? .currentCourses : .completedCourses
            cell.configure(for: configuration)
            return cell
        }
    }

    @IBAction func tappedOnCourseDateSummary(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: R.segue.dashboardViewController.showCourseDates, sender: self)
    }

    @IBAction func tappedOnCourseDateNextUp(_ sender: UITapGestureRecognizer) {
        let someCourseDate = CoreDataHelper.viewContext.fetchSingle(CourseDateHelper.FetchRequest.nextCourseDate).value
        guard let course = someCourseDate?.course else {
            return
        }

        AppNavigator.show(course: course)
    }

}
