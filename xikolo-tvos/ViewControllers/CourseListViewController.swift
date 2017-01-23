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
        self.courseDisplayMode = .bothSectioned

        super.viewDidLoad()

        resultsControllerDelegateImplementation.headerReuseIdentifier = "CourseHeaderView"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ShowCourseDetailSegue"?:
                let vc = segue.destination as! CourseTabBarController
                let cell = sender as! CourseCell
                let indexPath = collectionView!.indexPath(for: cell)
                let course = resultsController.object(at: indexPath!) as! Course
                vc.course = course
            default:
                break
        }
    }

}

extension CourseListViewController {

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo) {
        let view = view as! CourseHeaderView
        view.configure(section)
    }

}
