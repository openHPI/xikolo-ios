//
//  CourseContentTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CourseContentTableViewController: UITableViewController {

    var course: Course!
    
    var resultsController: NSFetchedResultsController!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation!
    
    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = course.name

        let request = CourseItemHelper.getItemRequest(course)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "section.title")

        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: resultsController, cellReuseIdentifier: "CourseItemCell")
        resultsControllerDelegateImplementation.delegate = self
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }
        CourseSectionHelper.syncCourseSections(course).flatMap { sections in
            sections.map { section in
                CourseItemHelper.syncCourseItems(section)
            }.sequence()
        }
    }
    
    func showItem(item: CourseItem) {
        switch item.content {
        case is Video:
            performSegueWithIdentifier("ShowVideoView", sender: item)
        case is Quiz:
            performSegueWithIdentifier("ShowQuizWebView", sender: item)
        case is RichText:
            performSegueWithIdentifier("ShowRichTextView", sender: item)
        default:
            // TODO: show error: unsupported type
            break
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = resultsController!.objectAtIndexPath(indexPath) as! CourseItem
        showItem(item)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "ShowVideoView":
            let videoView = segue.destinationViewController as! VideoViewController
            let item = sender as! CourseItem
            videoView.courseItem = item
            break
        case "ShowQuizWebView":
            let quizView = segue.destinationViewController as! QuizWebViewController
            quizView.courseItem = sender as! CourseItem
            break
        case "ShowRichTextView":
            let richtextView = segue.destinationViewController as! RichtextViewController
            richtextView.courseItem = sender as! CourseItem
            break
        default:
            break
        }
    }
}

extension CourseContentTableViewController : TableViewResultsControllerDelegateImplementationDelegate {

    func configureTableCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let cell = cell as! CourseItemCell

        let item = resultsController.objectAtIndexPath(indexPath) as! CourseItem
        cell.configure(item)
    }

}
