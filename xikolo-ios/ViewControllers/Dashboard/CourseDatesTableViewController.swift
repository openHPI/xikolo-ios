//
//  DeadlinesTableViewController.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 15.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet

class CourseDatesTableViewController : UITableViewController {

    @IBOutlet var loginButton: UIBarButtonItem!

    var courseActivityViewController: CourseActivityViewController?

    var resultsController: NSFetchedResultsController<CourseDate>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<CourseDate>!

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .automatic
        }

        // register custom section header view
        let nib = UINib(nibName: "CourseDateHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "CourseDateHeader")

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        // setup table view data
        TrackingHelper.createEvent(.visitedDashboard, resource: nil)

        let fetchRequest = CourseDateHelper.FetchRequest.allCourseDates
        fetchRequest.predicate = NSPredicate(format: "course != nil")
        resultsController = CoreDataHelper.createResultsController(fetchRequest, sectionNameKeyPath: "course.title")
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView,
                                                                                                   resultsController: [resultsController],
                                                                                                   cellReuseIdentifier: "CourseDateCell")
        let configuration = TableViewResultsControllerConfigurationWrapper(CourseDatesTableViewConfiguration())
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }

        self.refresh()

        self.tableView.reloadData()
        self.setupEmptyState()
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

        self.courseActivityViewController?.refresh()
        if UserProfileHelper.isLoggedIn() {
            CourseDateHelper.syncAllCourseDates().onComplete { _ in
                stopRefreshControl()
            }
        } else {
           stopRefreshControl()
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CourseDateHeader")
        let header = cell as! CourseDateHeader

        let minPadding = self.tableView.separatorInset.left
        header.leadingConstraint.constant = minPadding
        header.trailingConstraint.constant = minPadding
        header.titleBackgroundView.backgroundColor = Brand.TintColorSecond
        header.titleView.text = self.resultsController.sections?[section].name
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedCourseActivity"?:
            self.courseActivityViewController = segue.destination as? CourseActivityViewController
        default:
            super.prepare(for: segue, sender: sender)
        }
    }

}

extension CourseDatesTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (controller, dataIndexPath) = resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath)!
        let courseDate = controller.object(at: dataIndexPath)

        guard let course = courseDate.course else {
            print("Error: Did not find course for course date")
            return
        }

        let storyboard = UIStoryboard(name: "TabCourses", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CourseDecisionViewController") as! CourseDecisionViewController
        vc.course = course
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

struct CourseDatesTableViewConfiguration : TableViewResultsControllerConfiguration {

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<CourseDate>, indexPath: IndexPath) {
        let cell = cell as! CourseDateCell
        let courseDate = controller.object(at: indexPath)
        cell.configure(courseDate)
    }

    func shouldShowHeader() -> Bool {
        return false
    }

}

extension CourseDatesTableViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        guard let tableHeaderView = self.tableView.tableHeaderView else {
            return 0
        }
        // DZNEmptyDataSet has some undefined behavior for the verticalOffset when using a custom tableView header.
        // Dividing it again by 2 will do the trick.
        return tableHeaderView.frame.height/2/2
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
    
}
