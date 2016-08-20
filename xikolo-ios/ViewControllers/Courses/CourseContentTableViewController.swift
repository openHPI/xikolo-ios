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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = course.title

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
        TrackingHelper.sendEvent("VISITED_ITEM", resource: item)

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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "ShowVideoView":
            let videoView = segue.destinationViewController as! VideoViewController
            let item = sender as! CourseItem
            videoView.courseItem = item
            break
        case "ShowQuizWebView":
            let webView = segue.destinationViewController as! WebViewController
            let courseItem = sender as! CourseItem
            if let courseID = courseItem.section?.course?.id {
                let courseURL = Routes.COURSES_URL + courseID
                let quizpathURL = "/items/" + courseItem.id
                let url = courseURL + quizpathURL
                webView.url = url
            }
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

extension CourseContentTableViewController { // TableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = resultsController.objectAtIndexPath(indexPath) as! CourseItem
        showItem(item)
    }

}

extension CourseContentTableViewController : TableViewResultsControllerDelegateImplementationDelegate {

    func configureTableCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let cell = cell as! CourseItemCell

        let item = resultsController.objectAtIndexPath(indexPath) as! CourseItem
        cell.configure(item)
    }

}
