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

    @IBOutlet var courseDeadlinesContainerHeight: NSLayoutConstraint!
    @IBOutlet var courseStartsContainerHeight: NSLayoutConstraint!
    @IBOutlet var courseActivityContainerHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        CourseDateHelper.syncCourseDates()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "EmbedCourseDeadlines"?:
            let vc = segue.destination as! CourseDeadlinesTableViewController
            vc.delegate = self
        case "EmbedCourseStarts"?:
            let vc = segue.destination as! CourseStartsTableViewController
            vc.delegate = self
        case "EmbedCourseActivity"?:
            let vc = segue.destination as! CourseActivityViewController
            vc.delegate = self
        default:
            break
        }
    }

}

extension DashboardViewController : CourseDeadlinesTableViewControllerDelegate {

    func changedCourseDeadlinesTableViewHeight(_ height: CGFloat) {
        DispatchQueue.main.async {
            self.courseDeadlinesContainerHeight.constant = height
        }
    }

}

extension DashboardViewController : CourseStartsTableViewControllerDelegate {

    func changedCourseStartsTableViewHeight(_ height: CGFloat) {
        DispatchQueue.main.async {
            self.courseStartsContainerHeight.constant = height
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
