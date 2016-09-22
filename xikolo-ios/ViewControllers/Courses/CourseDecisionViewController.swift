//
//  CourseDecisionViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class CourseDecisionViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleView: UILabel!

    var containerContentViewController: UIViewController?
    var course: Course!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateContainerView(0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(switchViewController), name: NotificationKeys.dropdownCourseContentKey, object: nil)
    }

    func switchViewController(notification: NSNotification) {
        let userInfo : [String:Int] = notification.userInfo as! [String:Int]
        if let position = userInfo[NotificationKeys.dropdownCourseContentKey] {
            updateContainerView(position)
        }
    }

    func updateContainerView(position: Int) {
        // TODO: Animation?
        if let vc = containerContentViewController {
            vc.willMoveToParentViewController(nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            containerContentViewController = nil
        }

        let storyboard = UIStoryboard(name: "TabCourses", bundle: nil)
        switch position {
        case 0:
            let vc = storyboard.instantiateViewControllerWithIdentifier("CourseContentTableViewController") as! CourseContentTableViewController
            vc.course = course
            containerView.addSubview(vc.view)
            vc.view.frame = containerView.bounds
            addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            containerContentViewController = vc
            titleView.text = NSLocalizedString("Learnings", comment: "")
        case 1:
            let vc = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
            if let slug = course.slug {
                vc.url = Routes.COURSES_URL + slug + "/pinboard"
            }
            containerView.addSubview(vc.view)
            vc.view.frame = containerView.bounds
            addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            containerContentViewController = vc
            titleView.text = NSLocalizedString("Discussions", comment: "")
        case 2:
            let vc = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
            if let slug = course.slug {
                vc.url = Routes.COURSES_URL + slug
            }
            containerView.addSubview(vc.view)
            vc.view.frame = containerView.bounds
            addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            containerContentViewController = vc
            titleView.text = NSLocalizedString("Course Details", comment: "")
        default:
            break
        }
    }

    @IBAction func unwindSegueToCourseContent(segue: UIStoryboardSegue) { }

}
