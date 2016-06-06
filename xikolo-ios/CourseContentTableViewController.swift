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
    
    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if course.id != nil {
            let request = CourseItemHelper.getItemRequest(course)
            resultsController = CourseItemHelper.initializeItemResultsController(request)
            resultsController.delegate = self
            do {
                try resultsController.performFetch()
            } catch {
                // TODO: Error handling.
            }
            CourseSectionHelper.syncCourseSections(course)
            
            // TODO: Replace the following. e.g. add a completion handler to syncCourseSections and execute it there.
            let appDelegate = UIApplication.sharedApplication().delegate as! AbstractAppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            do {
                let sectionRequest = CourseSectionHelper.getSectionRequest(course)
                let sections = try managedContext.executeFetchRequest(sectionRequest)
                for section in sections {
                    CourseItemHelper.syncCourseItems(section as! CourseSection)
                }
            } catch {
                // TODO: Error handling
            }
        }

    }
    
    func showItem(item: CourseItem) {
        switch item.content {
        case is Video:
            performSegueWithIdentifier("ShowVideoView", sender: item)
        case is Quiz:
            performSegueWithIdentifier("ShowQuizWebView", sender: item)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseContentTableViewCell", forIndexPath: indexPath) as! CourseContentTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: CourseContentTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item = resultsController.objectAtIndexPath(indexPath) as! CourseItem
        cell.courseItem = item
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "ShowVideoView":
            let videoView = segue.destinationViewController as! VideoViewController
            //let item = sender as! CourseItem
            //TODO: insert real CourseItem
            break
        case "ShowQuizWebView":
            let quizView = segue.destinationViewController as! QuizWebViewController
            quizView.courseItem = sender as! CourseItem
            break
        default:
            break
        }
    }
}

extension CourseContentTableViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        courseContentTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            courseContentTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            courseContentTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            courseContentTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            courseContentTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            // No need to update a cell that has not been loaded.
            if let cell = courseContentTableView.cellForRowAtIndexPath(indexPath!) as? CourseContentTableViewCell {
                configureCell(cell, atIndexPath: indexPath!)
            }
        case .Move:
            courseContentTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            courseContentTableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        courseContentTableView.endUpdates()
    }
    
}
