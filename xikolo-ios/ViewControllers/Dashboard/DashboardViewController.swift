//
//  DashboardViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import PinpointKit

class DashboardViewController : AbstractTabContentViewController {

    @IBOutlet var courseDatesContainerHeight: NSLayoutConstraint!
    @IBOutlet var courseActivityContainerHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        TrackingHelper.sendEvent("VISITED_DASHBOARD", resource: nil)
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        CourseDateHelper.syncCourseDates()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "EmbedCourseDates"?:
            let vc = segue.destination as! CourseDatesTableViewController
            vc.delegate = self
        case "EmbedCourseActivity"?:
            let vc = segue.destination as! CourseActivityViewController
            vc.delegate = self
        default:
            break
        }
    }

}

extension DashboardViewController : CourseDatesTableViewControllerDelegate {

    func changedCourseDatesTableViewHeight(_ height: CGFloat) {
        DispatchQueue.main.async {
            self.courseDatesContainerHeight.constant = height
        }
    }

}

extension DashboardViewController : CourseActivityViewControllerDelegate {

    func changedCourseActivityTableViewHeight(_ height: CGFloat) {
        DispatchQueue.main.async {
            self.courseActivityContainerHeight.constant = height
        }
    }

}
