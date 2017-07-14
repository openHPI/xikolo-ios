//
//  CourseActivityRow.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 16.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CourseActivityRow : UITableViewCell {

    var resultsController: NSFetchedResultsController<Course>!
    var resultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation<Course>!

    @IBOutlet var collectionView: UICollectionView!

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            initCollectionView()
        }
    }

    func initCollectionView() {
        // TODO: proper API call and cell UI
        var request: NSFetchRequest<Course>
        if UserProfileHelper.isLoggedIn() {
            request = CourseHelper.getEnrolledAccessibleCoursesRequest()
        } else {
            request = CourseHelper.getInterestingCoursesRequest()
        }
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)

        resultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(collectionView, resultsControllers: [resultsController], cellReuseIdentifier: "LastCourseCell")
        let configuration = CollectionViewResultsControllerConfigurationWrapper(CourseActivityRowConfiguration())
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        collectionView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }

        CourseHelper.refreshCourses()
    }

}

extension CourseActivityRow {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let visualCourse = resultsController.object(at: indexPath)
        let course = try! CourseHelper.getByID(visualCourse.id)
        AppDelegate.instance().goToCourse(course!)
    }
    
}

struct CourseActivityRowConfiguration : CollectionViewResultsControllerConfiguration {

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<Course>, indexPath: IndexPath) {
        let cell = cell as! CourseCell
        let course = controller.object(at: indexPath)
        cell.configure(course)
    }

}

extension CourseActivityRow : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = 300
        let itemHeight = 240
        return CGSize(width: itemWidth, height: itemHeight)
    }

}
