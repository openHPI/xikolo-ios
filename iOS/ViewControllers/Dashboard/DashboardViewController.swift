//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

class DashboardViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 250

        self.addRefreshControl()
        self.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackingHelper.shared.createEvent(.visitedDashboard)
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
            cell.delegate = self
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

extension DashboardViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        let courseFuture = CourseHelper.syncAllCourses()
        if Brand.default.features.showCourseDatesOnDashboard {
            return courseFuture.flatMap { _ in
                return CourseDateHelper.syncAllCourseDates()
            }.asVoid()
        } else {
            return courseFuture.asVoid()
        }
    }

    func didRefresh() {
        guard Brand.default.features.showCourseDatesOnDashboard else { return }
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }

}

extension DashboardViewController: CourseDateOverviewDelegate {

    func openCourseDateList() {
        self.performSegue(withIdentifier: R.segue.dashboardViewController.showCourseDates, sender: self)
    }

    func openCourse(_ course: Course) {
        AppNavigator.show(course: course)
    }

}
