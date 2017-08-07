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
        updateView()

        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ShowCourseDetailSegue"?:
                let vc = segue.destination as! CourseTabBarController
                let cell = sender as! CourseCell
                let indexPath = collectionView!.indexPath(for: cell)
                let (controller, dataIndexPath) = resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath!)!
                let course = controller.object(at: dataIndexPath) as! Course
                vc.course = course
            default:
                break
        }
    }

}
