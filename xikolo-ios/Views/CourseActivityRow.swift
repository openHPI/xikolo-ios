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

    var resultsController: NSFetchedResultsController!
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
        let request = CourseHelper.getMyCoursesRequest()
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

    func configureCollectionCell(cell: UICollectionViewCell, indexPath: NSIndexPath) {
        let cell = cell as! CourseCell

        let course = resultsController.objectAtIndexPath(indexPath) as! Course
        cell.configure(course)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let course = resultsController.objectAtIndexPath(indexPath) as! Course
        AppDelegate.instance().goToCourse(course)
    }
    
}

extension CourseActivityRow : UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth = 300
        let itemHeight = 240
        return CGSize(width: itemWidth, height: itemHeight)
    }

}
