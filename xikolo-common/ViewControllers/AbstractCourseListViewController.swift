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
        case explore
        case bothSectioned
    }

    var resultsControllers: [NSFetchedResultsController<Course>]!
    var resultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation<Course>!
    var contentChangeOperations: [[AnyObject?]] = []
    var courseDisplayMode: CourseDisplayMode = .enrolledOnly

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        updateView()

        CourseHelper.refreshCourses()
    }

    func updateView() {
        var request: NSFetchRequest<Course>
        switch courseDisplayMode {
        case .enrolledOnly:
            let currentRequest = CourseHelper.getEnrolledCurrentCoursesRequest()
            let selfPacedRequest = CourseHelper.getEnrolledSelfPacedCoursesRequest()
            let upcomingRequest = CourseHelper.getEnrolledUpcomingCoursesRequest()
            let completedRequest = CourseHelper.getCompletedCoursesRequest()
            resultsControllers = [CoreDataHelper.createResultsController(currentRequest, sectionNameKeyPath: "current_section"),
                                  CoreDataHelper.createResultsController(selfPacedRequest, sectionNameKeyPath: "selfpaced_section"),
                                  CoreDataHelper.createResultsController(upcomingRequest, sectionNameKeyPath: "upcoming_section"),
                                  CoreDataHelper.createResultsController(completedRequest, sectionNameKeyPath: "completed_section")]
        case .explore, .all:
            let upcomingRunningRequest = CourseHelper.getInterestingCoursesRequest()
            let selfpacedRequest = CourseHelper.getPastCoursesRequest()
            resultsControllers = [CoreDataHelper.createResultsController(upcomingRunningRequest, sectionNameKeyPath: "interesting_section"),
                                  CoreDataHelper.createResultsController(selfpacedRequest, sectionNameKeyPath: "selfpaced_section")]
        case .bothSectioned:
            request = CourseHelper.getSectionedRequest()
            resultsControllers = [CoreDataHelper.createResultsController(request, sectionNameKeyPath: "is_enrolled_section")]
        }

        resultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(collectionView!, resultsControllers: resultsControllers, cellReuseIdentifier: "CourseCell")
        resultsControllerDelegateImplementation.headerReuseIdentifier = "CourseHeaderView"
        let configuration = CollectionViewResultsControllerConfigurationWrapper(CourseListViewConfiguration())
        resultsControllerDelegateImplementation.configuration = configuration
        for rC in resultsControllers {
            rC.delegate = resultsControllerDelegateImplementation
        }
        collectionView!.dataSource = resultsControllerDelegateImplementation

        do {
            for rC in resultsControllers {
                try rC.performFetch()
            }
        } catch {
            // TODO: Error handling.
        }
        self.collectionView?.reloadData()
    }

}

struct CourseListViewConfiguration : CollectionViewResultsControllerConfiguration {

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<Course>, indexPath: IndexPath) {
        let cell = cell as! CourseCell
        let course = controller.object(at: indexPath)
        cell.configure(course)
    }

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo) {
        let view = view as! CourseHeaderView
        view.configure(section)
    }

}
