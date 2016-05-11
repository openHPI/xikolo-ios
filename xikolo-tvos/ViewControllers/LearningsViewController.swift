//
//  LearningsViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 06.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class LearningsViewController : UIViewController {

    @IBOutlet weak var sectionTableView: UITableView!

    var courseTabBarController: CourseTabBarController!
    var course: Course!

    var sectionResultsController: NSFetchedResultsController!

    override func viewDidLoad() {
        courseTabBarController = self.tabBarController as! CourseTabBarController
        course = courseTabBarController.course

        if course.id != nil {
            let request = CourseSectionHelper.getSectionRequest(course)
            sectionResultsController = CourseHelper.initializeFetchedResultsController(request)
            sectionResultsController.delegate = self

            do {
                try sectionResultsController.performFetch()
            } catch {
                // TODO: Error handling.
            }

            CourseSectionHelper.syncCourseSections(course)
        }
    }

}

extension LearningsViewController : UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = sectionResultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseSectionCell", forIndexPath: indexPath) as! CourseSectionCell
        self.configureSectionCell(cell, atIndexPath: indexPath)
        return cell
    }

    func configureSectionCell(cell: CourseSectionCell, atIndexPath indexPath: NSIndexPath) {
        let section = sectionResultsController.objectAtIndexPath(indexPath) as! CourseSection
        cell.configure(section)
    }

}

extension LearningsViewController : NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        sectionTableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            sectionTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            sectionTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            sectionTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            sectionTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            // No need to update a cell that has not been loaded.
            if let cell = sectionTableView.cellForRowAtIndexPath(indexPath!) as? CourseSectionCell {
                configureSectionCell(cell, atIndexPath: indexPath!)
            }
        case .Move:
            sectionTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            sectionTableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        sectionTableView.endUpdates()
    }

}
