//
//  AbstractCourseListViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class AbstractCourseListViewController : UICollectionViewController {

    enum CourseDisplayMode {
        case EnrolledOnly
        case All
    }

    let cellReuseIdentifier = "CourseCell"

    var resultsController: NSFetchedResultsController!
    var contentChangeOperations: [[AnyObject?]] = []

    var courseDisplayMode: CourseDisplayMode = .All

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        var request: NSFetchRequest
        switch courseDisplayMode {
            case .EnrolledOnly:
                request = CourseHelper.getMyCoursesRequest()
            case .All:
                request = CourseHelper.getAllCoursesRequest()
        }
        resultsController = CourseHelper.initializeFetchedResultsController(request)
        resultsController.delegate = self

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }

        CourseHelper.refreshCourses()
    }

}

extension AbstractCourseListViewController {

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return resultsController.sections!.count
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sections = resultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> CourseCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! CourseCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }

    func configureCell(cell: CourseCell, indexPath: NSIndexPath) {
        let course = resultsController.objectAtIndexPath(indexPath) as! Course

        cell.nameLabel.text = course.name
        cell.teacherLabel.text = course.teachers
        cell.dateLabel.text = course.language

        ImageProvider.loadImage(course.image_url!, imageView: cell.backgroundImage)

        cell.layer.cornerRadius = 3
    }

}

extension AbstractCourseListViewController : NSFetchedResultsControllerDelegate {

    enum FetchedResultsChangeContext : UInt {
        case Section
        case Object
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        contentChangeOperations.removeAll()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        contentChangeOperations.append([FetchedResultsChangeContext.Section.rawValue, type.rawValue, NSIndexSet(index: sectionIndex)])
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        contentChangeOperations.append([FetchedResultsChangeContext.Object.rawValue, type.rawValue, indexPath, newIndexPath])
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView!.performBatchUpdates({
            let collectionView = self.collectionView!
            for change in self.contentChangeOperations {
                let type = NSFetchedResultsChangeType(rawValue:change[1]! as! UInt)!
                switch FetchedResultsChangeContext(rawValue:change[0]! as! UInt)! {
                    case .Section:
                        let indexSet = change[2] as? NSIndexSet
                        switch type {
                            case .Insert:
                                collectionView.insertSections(indexSet!)
                            case .Delete:
                                collectionView.deleteSections(indexSet!)
                            case .Move:
                                break
                            case .Update:
                            break
                        }
                    case .Object:
                        let indexPath = change[2] as? NSIndexPath
                        let newIndexPath = change[3] as? NSIndexPath
                        switch type {
                            case .Insert:
                                collectionView.insertItemsAtIndexPaths([newIndexPath!])
                            case .Delete:
                                collectionView.deleteItemsAtIndexPaths([indexPath!])
                            case .Update:
                                // No need to update a cell that has not been loaded.
                                if let cell = collectionView.cellForItemAtIndexPath(indexPath!) as? CourseCell {
                                    self.configureCell(cell, indexPath: indexPath!)
                                }
                            case .Move:
                                collectionView.deleteItemsAtIndexPaths([indexPath!])
                                collectionView.insertItemsAtIndexPaths([newIndexPath!])
                        }
                }
            }
        }, completion: nil)
    }

}
