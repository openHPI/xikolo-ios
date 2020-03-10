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
        let sectionNameKeyPath: String? = {
            if #available(iOS 13, *) {
                return "relativeDateTime"
            } else {
                return nil
            }
        }()

        let reuseIdentifier = R.reuseIdentifier.courseDateCell.identifier
        let resultsController = CoreDataHelper.createResultsController(CourseDateHelper.FetchRequest.allCourseDates, sectionNameKeyPath: sectionNameKeyPath)
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

        self.setupEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13, *) {
            // workaround to correct show table view section header on load
            if animated {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            } else {
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            }
        }
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

        if #available(iOS 13, *) {} else {
            cell.backgroundColor = ColorCompatibility.systemBackground
        }
    }

    func titleForDefaultHeader(forSection section: Int) -> String? {
        return self.dataSource?.sectionInfos?[section].name
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
