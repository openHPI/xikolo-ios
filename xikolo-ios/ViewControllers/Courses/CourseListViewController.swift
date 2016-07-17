//
//  CourseListViewController.swift
//  xikolo-ios
//
//  Created by Arne Boockmeyer on 08/07/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class CourseListViewController : AbstractCourseListViewController {

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
            showMyCoursesOnly(true)
        }
    }

    internal func showMyCoursesOnly(showMyCourses: Bool) {
        self.courseDisplayMode = showMyCourses ? .EnrolledOnly : .All
        updateView()
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
                let vc = segue.destinationViewController as! CourseContentTableViewController
                let cell = sender as! CourseCell
                let indexPath = collectionView!.indexPathForCell(cell)
                let course = resultsController.objectAtIndexPath(indexPath!) as! Course
                vc.course = course
            default:
                break
        }
    }

}

extension CourseListViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = collectionView.frame.size.width - (10 + 10) // section insets left + right
            return CGSize(width: width, height: width * 0.6)
    }

}
