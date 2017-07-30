//
//  DashboardViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import PinpointKit

class DashboardViewController : UIViewController {

    @IBOutlet var loginButton: UIBarButtonItem!

    @IBOutlet var courseDatesContainerHeight: NSLayoutConstraint!
    @IBOutlet var courseActivityContainerHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateAfterLogin()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DashboardViewController.updateAfterLogin),
                                               name: NotificationKeys.loginStateChangedKey,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        CourseDateHelper.syncCourseDates()
    }

    func updateAfterLogin() {
        self.navigationItem.rightBarButtonItem = UserProfileHelper.isLoggedIn() ? nil : self.loginButton
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

    @IBAction func unwindLogin(_ segue: UIStoryboardSegue) { }

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
