//
//  CourseListViewController.swift
//  xikolo-ios
//
//  Created by Arne Boockmeyer on 08/07/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CoreData

class CourseListViewController : UICollectionViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var numberOfItemsPerRow = 1

    enum CourseDisplayMode {
        case enrolledOnly
        case all
        case explore
        case bothSectioned
    }

    var resultsController: [NSFetchedResultsController<NSFetchRequestResult>]!
    var resultsMultipleControllerDelegateImplementation: CollectionViewMultipleResultsControllerDelegateImplementation!
    var contentChangeOperations: [[AnyObject?]] = []

    var courseDisplayMode: CourseDisplayMode = .enrolledOnly

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        self.collectionView?.emptyDataSetSource = nil
        self.collectionView?.emptyDataSetDelegate = nil
    }

    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if UserProfileHelper.isLoggedIn() {
                courseDisplayMode = .enrolledOnly
            } else {
                sender.selectedSegmentIndex = 1
                performSegue(withIdentifier: "ShowLogin", sender: sender)
            }
        case 1:
            courseDisplayMode = UserProfileHelper.isLoggedIn() ? .explore : .all
        default:
            break
        }
        updateView()
    }

    override func viewDidLoad() {
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
        }
        if !UserProfileHelper.isLoggedIn() {
            segmentedControl.selectedSegmentIndex = 1
            courseDisplayMode = .all
        }
        updateView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.horizontalSizeClass {
        case .compact, .unspecified:
            numberOfItemsPerRow = 1
        case .regular:
            numberOfItemsPerRow = 2
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            // Force redraw
            self.collectionView!.performBatchUpdates(nil, completion: nil)
        }, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ShowCourseContent"?:
                let vc = segue.destination as! CourseDecisionViewController
                let cell = sender as! CourseCell
                let indexPath = collectionView!.indexPath(for: cell)
                let course = resultsController[indexPath!.section].fetchedObjects?[indexPath!.row] as! Course
                vc.course = course
            default:
                break
        }
    }

    func updateView() {
        var request: NSFetchRequest<NSFetchRequestResult>
        switch courseDisplayMode {
        case .enrolledOnly:
            request = CourseHelper.getEnrolledCoursesRequest()
            resultsController = [CoreDataHelper.createResultsController(request, sectionNameKeyPath: "enrolled_section")]
        case .explore, .all:
            let upcomingRunningRequest = CourseHelper.getInterestingCoursesRequest()
            let selfpacedRequest = CourseHelper.getPastCoursesRequest()
            resultsController = [CoreDataHelper.createResultsController(upcomingRunningRequest, sectionNameKeyPath: "interesting_section"),
                                 CoreDataHelper.createResultsController(selfpacedRequest, sectionNameKeyPath: "selfpaced_section")]
        default:
            break
        }
        resultsMultipleControllerDelegateImplementation = CollectionViewMultipleResultsControllerDelegateImplementation(collectionView!, resultsController: resultsController, cellReuseIdentifier: "CourseCell", headerReuseIdentifier: "SectionTitleView")
        resultsMultipleControllerDelegateImplementation.delegate = self
        for rC in resultsController { rC.delegate = resultsMultipleControllerDelegateImplementation }
        collectionView!.dataSource = resultsMultipleControllerDelegateImplementation

        do {
            for rC in resultsController { try rC.performFetch() }
        } catch {
            // TODO: Error handling.
        }

        CourseHelper.refreshCourses()
    }

}

extension CourseListViewController : CollectionViewMultipleResultsControllerDelegateImplementationDelegate {

    func configureCollectionCell(_ cell: UICollectionViewCell, indexPath: IndexPath) {
        let cell = cell as! CourseCell

        let course = resultsController[indexPath.section].fetchedObjects?[indexPath.row] as! Course
        cell.configure(course)
    }

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo) {
        let view = view as! SectionTitleView
        view.configure(section.name)
    }
    
}


extension CourseListViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let blankSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
            let width = (collectionView.bounds.width - blankSpace) / CGFloat(numberOfItemsPerRow)
            return CGSize(width: width, height: width * 0.6)
    }

}
