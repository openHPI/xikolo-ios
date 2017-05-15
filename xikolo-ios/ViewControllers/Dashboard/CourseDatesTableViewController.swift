//
//  DeadlinesTableViewController.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 15.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import CoreData

class CourseDatesTableViewController : UITableViewController {

    var resultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation!

    weak var delegate: CourseDatesTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = CourseDateHelper.getCourseDatesRequest()

        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "course.title")

        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: [resultsController], cellReuseIdentifier: "CourseDateCell")
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
        delegate?.changedCourseDatesTableViewHeight(tableViewHeight())
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableCell(withIdentifier: "CourseDateHeader") as! CourseDateHeader
        header.titleBackgroundView.backgroundColor = Brand.TintColorSecond

        let sectionTitle = resultsController.sections?[section].name
        header.titleView.text = sectionTitle
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableViewHeight() -> CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }

}

extension CourseDatesTableViewController : TableViewResultsControllerDelegateImplementationDelegate {

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath) {
        
        let courseDate = controller.object(at: indexPath) as! CourseDate
        let cell = cell as! CourseDateCell
        cell.configure(courseDate)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (controller, dataIndexPath) = resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath)!
        let courseDate = controller.object(at: dataIndexPath) as! CourseDate
        if let course = try! CourseHelper.getByID(courseDate.course!.id) {
            AppDelegate.instance().goToCourse(course)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

protocol CourseDatesTableViewControllerDelegate: class {

    func changedCourseDatesTableViewHeight(_ height: CGFloat)

}
