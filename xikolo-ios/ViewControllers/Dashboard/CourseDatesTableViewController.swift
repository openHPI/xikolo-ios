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

    var resultsController: NSFetchedResultsController<CourseDate>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<CourseDate>!

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "CourseDateHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "CourseDateHeader")

        TrackingHelper.createEvent("VISITED_DASHBOARD", resource: nil)
        self.updateAfterLogin()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CourseDatesTableViewController.updateAfterLogin),
                                               name: NotificationKeys.loginStateChangedKey,
                                               object: nil)

        let request = CourseDateHelper.getCourseDatesRequest()
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "course.title")
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: [resultsController], cellReuseIdentifier: "CourseDateCell")
        let configuration = TableViewResultsControllerConfigurationWrapper(CourseDatesTableViewConfiguration())
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }
        setupEmptyState()
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
    }

    override func viewWillAppear(_ animated: Bool) {
        CourseDateHelper.syncCourseDates()
    }

    func updateAfterLogin() {
        self.navigationItem.rightBarButtonItem = UserProfileHelper.isLoggedIn() ? nil : self.loginButton
        CourseDateHelper.syncCourseDates()
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

}

extension CourseDatesTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (controller, dataIndexPath) = resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath)!
        let courseDate = controller.object(at: dataIndexPath)
        if let course = try! CourseHelper.getByID(courseDate.course!.id) {
            AppDelegate.instance().goToCourse(course)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let title: String
        if UserProfileHelper.isLoggedIn() {
            title = NSLocalizedString("There are no important course dates yet", comment: "")
        } else {
            title = NSLocalizedString("Please log in to see your personal deadlines", comment: "")
        }
        let attributedString = NSAttributedString(string: title)
        return attributedString
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let description: String
        if UserProfileHelper.isLoggedIn() {
            description = NSLocalizedString("Notifications about deadlines or new courses will appear here", comment: "")
        } else {
            description = NSLocalizedString("Course dates and deadlines are specific to your courses so we need to now what you're enrolled in", comment: "")
        }
        let attributedString = NSAttributedString(string: description)
        return attributedString
    }
    
}
