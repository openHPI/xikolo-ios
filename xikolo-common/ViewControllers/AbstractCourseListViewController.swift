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
        case BothSectioned
    }

    let cellReuseIdentifier = "CourseCell"

    var resultsController: NSFetchedResultsController!
    var resultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation!
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
                resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
            case .All:
                request = CourseHelper.getAllCoursesRequest()
                resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
            case .BothSectioned:
                request = CourseHelper.getSectionedRequest()
                resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "is_enrolled_section")
        }
        resultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(collectionView!)
        resultsControllerDelegateImplementation.delegate = self
        resultsController.delegate = resultsControllerDelegateImplementation

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
        cell.configure(course)
    }

}

extension AbstractCourseListViewController : CollectionViewResultsControllerDelegateImplementationDelegate {

    func configureCell(delegateImplementation: CollectionViewResultsControllerDelegateImplementation, cell: UICollectionViewCell, indexPath: NSIndexPath) {
        self.configureCell(cell as! CourseCell, indexPath: indexPath)
    }

}
