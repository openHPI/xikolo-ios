//
//  DeadlinesTableViewController.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 15.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import CoreData

class CourseStartsTableViewController : UITableViewController {

    var resultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation!

    weak var delegate: CourseStartsTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = CourseDateHelper.getCourseStartsRequest()
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)

        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: resultsController, cellReuseIdentifier: "CourseStartCell")
        resultsControllerDelegateImplementation.delegate = self
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        delegate?.changedCourseStartsTableViewHeight(tableViewHeight())
    }

    func tableViewHeight() -> CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }

}

extension CourseStartsTableViewController : TableViewResultsControllerDelegateImplementationDelegate {

    func configureTableCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let courseDate = resultsController.object(at: indexPath) as! CourseDate
        let cell = cell as! CourseDateCell
        cell.configure(courseDate)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let courseDate = resultsController.object(at: indexPath) as! CourseDate
        if let course = courseDate.course {
            AppDelegate.instance().goToCourse(course, content: .courseDetails)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

protocol CourseStartsTableViewControllerDelegate: class {
    
    func changedCourseStartsTableViewHeight(_ height: CGFloat)
    
}
