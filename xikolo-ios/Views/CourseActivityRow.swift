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

    var resultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var resultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation!

    @IBOutlet var collectionView: UICollectionView!

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            initCollectionView()
        }
    }

    func initCollectionView() {
        // TODO: proper API call and cell UI
        let request = CourseHelper.getMyAccessibleCoursesRequest()
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)

        resultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(collectionView, resultsController: resultsController, cellReuseIdentifier: "LastCourseCell")
        resultsControllerDelegateImplementation.delegate = self
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

extension CourseActivityRow : CollectionViewResultsControllerDelegateImplementationDelegate {

    func configureCollectionCell(_ cell: UICollectionViewCell, indexPath: IndexPath) {
        let cell = cell as! CourseCell

        let course = resultsController.object(at: indexPath) as! Course
        cell.configure(course)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = resultsController.object(at: indexPath) as! Course
        AppDelegate.instance().goToCourse(course)
    }
    
}

extension CourseActivityRow : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = 300
        let itemHeight = 240
        return CGSize(width: itemWidth, height: itemHeight)
    }

}
