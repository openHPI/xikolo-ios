//
//  CourseListViewController.swift
//  xikolo-tvos
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CourseListViewController : AbstractCourseListViewController {

    override func viewDidLoad() {
        self.courseDisplayMode = .BothSectioned

        super.viewDidLoad()

        resultsControllerDelegateImplementation.headerReuseIdentifier = "CourseHeaderView"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
            case "ShowCourseDetailSegue"?:
                let vc = segue.destinationViewController as! CourseTabBarController
                let cell = sender as! CourseCell
                let indexPath = collectionView!.indexPathForCell(cell)
                let course = resultsController.objectAtIndexPath(indexPath!) as! Course
                vc.course = course
            default:
                break
        }
    }

}

extension CourseListViewController {

    func configureCollectionHeaderView(view: UICollectionReusableView, section: NSFetchedResultsSectionInfo) {
        let view = view as! CourseHeaderView
        view.configure(section)
    }

}
