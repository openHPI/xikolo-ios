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
    
    @IBOutlet var courseContentTableView: UITableView!
    var course: Course!
    
    var resultsController: NSFetchedResultsController!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation!
    
    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = course.name

        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(courseContentTableView)
        resultsControllerDelegateImplementation.delegate = self

        let request = CourseItemHelper.getItemRequest(course)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "section.title")
        resultsController.delegate = resultsControllerDelegateImplementation
        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }
        CourseSectionHelper.syncCourseSections(course)

        // TODO: Replace the following. e.g. add a completion handler to syncCourseSections and execute it there.
        do {
            let sectionRequest = CourseSectionHelper.getSectionRequest(course)
            let sections = try CoreDataHelper.executeFetchRequest(sectionRequest)
            for section in sections {
                CourseItemHelper.syncCourseItems(section as! CourseSection)
            }
        } catch {
            // TODO: Error handling
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return resultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = resultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultsController.sections![section].name
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseContentTableViewCell", forIndexPath: indexPath)
        configureTableCell(cell, indexPath: indexPath)
        return cell
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
        let cell = cell as! CourseContentTableViewCell

        let item = resultsController.objectAtIndexPath(indexPath) as! CourseItem
        cell.courseItem = item
    }

}
