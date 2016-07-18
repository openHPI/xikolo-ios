//
//  CourseListViewController.swift
//  xikolo-ios
//
//  Created by Arne Boockmeyer on 08/07/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class CourseListViewController : AbstractCourseListViewController {

    var numberOfItemsPerRow = 1

    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            showMyCoursesOnly(false)
        case 1:
            if UserProfileHelper.isLoggedIn() {
                showMyCoursesOnly(true)
            } else {
                sender.selectedSegmentIndex = 0
                performSegueWithIdentifier("ShowLoginForMyCourses", sender: sender) // maybe switch to My Courses after succesful login?
            }
        default:
            break
        }
    }

    internal func showMyCoursesOnly(showMyCourses: Bool) {
        self.courseDisplayMode = showMyCourses ? .EnrolledOnly : .All
        updateView()
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        switch traitCollection.horizontalSizeClass {
        case UIUserInterfaceSizeClass.Compact, UIUserInterfaceSizeClass.Unspecified:
            numberOfItemsPerRow = 1
        case UIUserInterfaceSizeClass.Regular:
            numberOfItemsPerRow = 2
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ context in
            // Force redraw
            self.collectionView!.performBatchUpdates(nil, completion: nil)
        }, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
            case "ShowCourseDetailSegue"?:
                let vc = segue.destinationViewController as! CourseDecisionViewController
                let cell = sender as! CourseCell
                let indexPath = collectionView!.indexPathForCell(cell)
                let course = resultsController.objectAtIndexPath(indexPath!) as! Course
                vc.course = course
            case "ShowCourseDetails"?:
                let vc = segue.destinationViewController as! CourseDetailsWebViewController
                let course = sender as! Course
                vc.course = course
            default:
                break
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case "ShowCourseDetailSegue":
            let cell = sender as! CourseCell
            let indexPath = collectionView!.indexPathForCell(cell)
            let course = resultsController.objectAtIndexPath(indexPath!) as! Course
            if course.is_enrolled {
                return true
            } else {
                performSegueWithIdentifier("ShowCourseDetails", sender: course)
                return false
            }
        default:
            return true
        }
    }

    @IBAction func unwindToCourseListViewController(segue: UIStoryboardSegue) { }

}

extension CourseListViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let blankSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
            let width = (collectionView.bounds.width - blankSpace) / CGFloat(numberOfItemsPerRow)
            return CGSize(width: width, height: width * 0.6)
    }

}
