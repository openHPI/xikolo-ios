//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import UIKit

class CourseDateListViewController: UITableViewController {

    private var dataSource: CoreDataTableViewDataSource<CourseDateListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefreshControl()

        // setup table view data
        let reuseIdentifier = R.reuseIdentifier.courseDateCell.identifier
        let resultsController = CoreDataHelper.createResultsController(CourseDateHelper.FetchRequest.allCourseDates, sectionNameKeyPath: nil)
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

        self.setupEmptyState()
    }

}

extension CourseDateListViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let courseDate = self.dataSource.object(at: indexPath)

        guard let course = courseDate.course else {
            log.warning("Did not find course for course date")
            return
        }

        self.appNavigator?.show(course: course)
    }

}

extension CourseDateListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: CourseDateCell, for object: CourseDate) {
        cell.configure(for: object)
    }

}

extension CourseDateListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseHelper.syncAllCourses().map { _ in
            return CourseDateHelper.syncAllCourseDates()
        }.asVoid()
    }

}

extension CourseDateListViewController: EmptyStateDataSource, EmptyStateDelegate {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.course-dates.no-dates.title", comment: "title for empty course dates list if logged in")
    }

    var emptyStateDetailText: String? {
        return NSLocalizedString("empty-view.course-dates.no-dates.description", comment: "description for empty course dates list if logged in")
    }

    func didTapOnEmptyStateView() {
        self.refresh()
    }

    func setupEmptyState() {
        self.tableView.emptyStateDataSource = self
        self.tableView.emptyStateDelegate = self
        self.tableView.tableFooterView = UIView()
    }

}
