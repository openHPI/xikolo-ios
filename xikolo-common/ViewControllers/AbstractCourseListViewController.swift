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

    var resultsControllers: [NSFetchedResultsController<Course>] = []
    var resultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation<Course>!
    var contentChangeOperations: [[AnyObject?]] = []
    var courseDisplayMode: CourseDisplayMode = .enrolledOnly {
        didSet {
            if self.courseDisplayMode != oldValue {
                self.updateView()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateView()
        CourseHelper.syncAllCourses()
    }

    func updateView(){
        switch courseDisplayMode {
        case .enrolledOnly:
            resultsControllers = [CoreDataHelper.createResultsController(CourseHelper.FetchRequest.enrolledCurrentCoursesRequest, sectionNameKeyPath: "current_section"),
                                  CoreDataHelper.createResultsController(CourseHelper.FetchRequest.enrolledUpcomingCourses, sectionNameKeyPath: "upcoming_section"),
                                  CoreDataHelper.createResultsController(CourseHelper.FetchRequest.enrolledSelfPacedCourses, sectionNameKeyPath: "selfpaced_section"),
                                  CoreDataHelper.createResultsController(CourseHelper.FetchRequest.completedCourses, sectionNameKeyPath: "completed_section")]
        case .explore:
            resultsControllers = [CoreDataHelper.createResultsController(CourseHelper.FetchRequest.interestingCoursesRequest, sectionNameKeyPath: "interesting_section"),
                                  CoreDataHelper.createResultsController(CourseHelper.FetchRequest.pastCourses, sectionNameKeyPath: "selfpaced_section")]
        case .all:
            resultsControllers = [CoreDataHelper.createResultsController(CourseHelper.FetchRequest.currentCourses, sectionNameKeyPath: "current_section"),
                                  CoreDataHelper.createResultsController(CourseHelper.FetchRequest.upcomingCourses, sectionNameKeyPath: "upcoming_section"),
                                  CoreDataHelper.createResultsController(CourseHelper.FetchRequest.selfpacedCourses, sectionNameKeyPath: "selfpaced_section")]
        case .bothSectioned:
            resultsControllers = [CoreDataHelper.createResultsController(CourseHelper.FetchRequest.allCoursesSectioned, sectionNameKeyPath: "is_enrolled_section")]
        }

        resultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(collectionView, resultsControllers: resultsControllers, cellReuseIdentifier: "CourseCell")
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
            print(error)
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
