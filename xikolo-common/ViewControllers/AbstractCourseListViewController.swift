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
        resultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(collectionView!, resultsController: resultsController, cellReuseIdentifier: "CourseCell")
        resultsControllerDelegateImplementation.delegate = self
        resultsController.delegate = resultsControllerDelegateImplementation
        collectionView!.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }

        CourseHelper.refreshCourses()
    }

}

extension AbstractCourseListViewController : CollectionViewResultsControllerDelegateImplementationDelegate {

    func configureCollectionCell(cell: UICollectionViewCell, indexPath: NSIndexPath) {
        let cell = cell as! CourseCell

        let course = resultsController.objectAtIndexPath(indexPath) as! Course
        cell.configure(course)
    }

}
