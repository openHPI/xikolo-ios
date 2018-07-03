//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import DZNEmptyDataSet
import UIKit

class CourseDatesListViewController: UITableViewController {

    @IBOutlet private var loginButton: UIBarButtonItem!

    var courseActivityViewController: CourseActivityViewController?

    var resultsController: NSFetchedResultsController<CourseDate>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<CourseDate>!

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // register custom section header view
        self.tableView.register(R.nib.courseDateHeader(), forHeaderFooterViewReuseIdentifier: R.nib.courseDateHeader.name)

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        // setup table view data
        let reuseIdentifier = R.reuseIdentifier.courseDateCell.identifier
        resultsController = CoreDataHelper.createResultsController(CourseDateHelper.FetchRequest.allCourseDates, sectionNameKeyPath: nil)
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView,
                                                                                                   resultsController: [resultsController],
                                                                                                   cellReuseIdentifier: reuseIdentifier)

        let configuration = CourseDatesTableViewConfiguration().wrapped
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            CrashlyticsHelper.shared.recordError(error)
            log.error(error)
        }

        self.tableView.reloadData()
        self.setupEmptyState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackingHelper.shared.createEvent(.visitedDashboard)
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
    }

    @objc func refresh() {
        self.tableView.reloadEmptyDataSet()
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

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.courseDateHeader.name)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.courseDatesListViewController.embedCourseActivity(segue: segue) {
            self.courseActivityViewController = typedInfo.destination
        }
    }

}

extension CourseDatesListViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (controller, dataIndexPath) = resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath)!
        let courseDate = controller.object(at: dataIndexPath)

        guard let course = courseDate.course else {
            log.warning("Did not find course for course date")
            return
        }

        AppNavigator.show(course: course)
    }

}

struct CourseDatesTableViewConfiguration: TableViewResultsControllerConfiguration {

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<CourseDate>, indexPath: IndexPath) {
        let cell = cell.require(toHaveType: CourseDateCell.self, hint: "CourseDatesViewController requires cell of type CourseDateCell")
        let courseDate = controller.object(at: indexPath)
        cell.configure(courseDate)
    }

}

extension CourseDatesListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        guard let tableHeaderView = self.tableView.tableHeaderView else {
            return 0
        }

        // DZNEmptyDataSet has some undefined behavior for the verticalOffset when using a custom tableView header.
        // Dividing it again by 2 will do the trick.
        return tableHeaderView.frame.height / 2 / 2
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.course-dates.no-dates.title",
                                      comment: "title for empty course dates list if logged in")
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description = NSLocalizedString("empty-view.course-dates.no-dates.description",
                                            comment: "description for empty course dates list if logged in")
        return NSAttributedString(string: description)
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        self.refresh()
    }

}
