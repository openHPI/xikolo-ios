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

    var course: Course?

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

        let request: NSFetchRequest<CourseDate>

        if let course = course {
            request = CourseDateHelper.FetchRequest.courseDates(for: course)
        } else {
            request = CourseDateHelper.FetchRequest.allCourseDates
        }

        let reuseIdentifier = R.reuseIdentifier.courseDateCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: sectionNameKeyPath)
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

        self.setupEmptyState()
        self.updateHeaderView()

        if self.course != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        }

        if let course = self.course {
            self.navigationItem.title = course.title
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.resizeTableHeaderView()
    }

    @objc private func close() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    private func updateHeaderView() {
        self.tableView.tableHeaderView?.isHidden = !self.tableView.hasItemsToDisplay
        self.tableView.resizeTableHeaderView()
    }

}

extension CourseDateListViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.course == nil else { return }

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
        cell.configure(for: object, inCourseContext: self.course != nil)

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

    func didRefresh() {
        self.updateHeaderView()
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
