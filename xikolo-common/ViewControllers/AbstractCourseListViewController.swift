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
        case enrolledOnly
        case all
        case bothSectioned
    }

    var resultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var resultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation!
    var contentChangeOperations: [[AnyObject?]] = []

    var courseDisplayMode: CourseDisplayMode = .all

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        updateView()
    }

    func updateView() {
        var request: NSFetchRequest<NSFetchRequestResult>
        switch courseDisplayMode {
            case .enrolledOnly:
                request = CourseHelper.getMyCoursesRequest()
                resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
            case .all:
                request = CourseHelper.getAllCoursesRequest()
                resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
            case .bothSectioned:
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

    func configureCollectionCell(_ cell: UICollectionViewCell, indexPath: IndexPath) {
        let cell = cell as! CourseCell

        let course = resultsController.object(at: indexPath) as! Course
        cell.configure(course)
    }

}
