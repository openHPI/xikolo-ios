//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import UIKit

class DashboardViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 250

        self.addRefreshControl()
        self.refresh()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
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
            let configuration: CourseListConfiguration = section == 1 ? .currentCourses : .completedCourses
            cell.delegate = self
            cell.configure(for: configuration)
            return cell
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.dashboardViewController.showCourseList(segue: segue) {
            if let configuration = sender as? CourseListConfiguration {
                typedInfo.destination.configuration = configuration
            }
        }
    }

    @objc private func coreDataChange(notification: Notification) {
        let courseDatesChanged = notification.includesChanges(for: CourseDate.self)
        let courseRefreshed = notification.includesChanges(for: Course.self, keys: [NSRefreshedObjectsKey])

        if courseDatesChanged || courseRefreshed {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
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

}

extension DashboardViewController: CourseOverviewDelegate {

    func openCourseList(for configuration: CourseListConfiguration) {
        self.performSegue(withIdentifier: R.segue.dashboardViewController.showCourseList, sender: configuration)
    }

}
