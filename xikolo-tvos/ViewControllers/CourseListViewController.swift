//
//  CourseListViewController.swift
//  xikolo-tvos
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class CourseListViewController : AbstractCourseListViewController {

    override func viewDidLoad() {
        self.courseDisplayMode = .BothSectioned

        super.viewDidLoad()
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

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "CourseHeaderView", forIndexPath: indexPath) as! CourseHeaderView
            let section = resultsController.sections![indexPath.section]
            view.configure(section)
            return view
        } else {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        }
    }

}
