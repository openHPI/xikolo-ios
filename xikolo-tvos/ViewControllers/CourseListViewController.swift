//
//  CourseListViewController.swift
//  xikolo-tvos
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class CourseListViewController : AbstractCourseListViewController {

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let course = resultsController.objectAtIndexPath(indexPath) as! Course
        openCourseDetailView(course)
    }

    func openCourseDetailView(course: Course) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CourseDetailTabBarController") as! CourseTabBarController
        vc.course = course
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
