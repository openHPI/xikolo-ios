//
//  CourseDetailsViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 26.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class CourseDetailsViewController : UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var abstractView: UITextView!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var languageView: UILabel!
    @IBOutlet weak var teacherView: UILabel!

    @IBOutlet weak var enrollButton: UIButton!
    @IBOutlet weak var unenrollButton: UIButton!

    weak var customPreferredFocusedView: UIView!
    override weak var preferredFocusedView: UIView? {
        return customPreferredFocusedView
    }

    var courseTabBarController: CourseTabBarController!
    var course: Course!

    var backgroundImageHelper: ViewControllerBlurredBackgroundHelper!

    override func viewDidLoad() {
        courseTabBarController = self.tabBarController as! CourseTabBarController
        course = courseTabBarController.course

        customPreferredFocusedView = super.preferredFocusedView

        backgroundImageHelper = ViewControllerBlurredBackgroundHelper(rootView: view)

        course.notifyOnChange(self, updatedHandler: { model in
            self.configureViews()
        }, deletedHandler: {
            // If the course was deleted, go back to course list.
            self.courseTabBarController.dismissViewControllerAnimated(true, completion: nil)
        })
        configureViews()
    }

    deinit {
        course.removeNotifications(self)
    }

    func configureViews() {
        titleView.text = course.name
        course.loadImage().onSuccess { image in
            self.courseImageView.image = image
            self.backgroundImageHelper.imageView.image = image
        }
        // TODO: Show abstract instead of description once we're on APIv2.
        abstractView.text = course.course_description

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle

        let startDateString: String? = course.start_date != nil ? dateFormatter.stringFromDate(course.start_date!) : nil
        let endDateString: String? = course.end_date != nil ? dateFormatter.stringFromDate(course.end_date!) : nil
        if let startDateString = startDateString, endDateString = endDateString {
            let format = NSLocalizedString("%@ to %@", comment: "<startDate> to <endDate>")
            let dateString = String.localizedStringWithFormat(format, startDateString, endDateString)
            dateView.text = dateString
        }

        if let language = course.language_translated {
            languageView.text = language
        }
        teacherView.text = course.teachers

        if course.is_enrolled {
            if enrollButton == UIScreen.mainScreen().focusedView {
                self.customPreferredFocusedView = unenrollButton
                setNeedsFocusUpdate()
            }
            enrollButton.hidden = true
            unenrollButton.hidden = false
        } else {
            if unenrollButton == UIScreen.mainScreen().focusedView {
                self.customPreferredFocusedView = enrollButton
                setNeedsFocusUpdate()
            }
            enrollButton.hidden = false
            unenrollButton.hidden = true
        }
    }

}

extension CourseDetailsViewController : AbstractLoginViewControllerDelegate {

    @IBAction func enroll(sender: UIButton) {
        // TODO: Move this somewhere more common. We probably need to do this all the time.
        if (!UserProfileHelper.isLoggedIn()) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            vc.delegate = self
            self.navigationController?.presentViewController(vc, animated: true, completion: nil)
        } else {
            createEnrollment()
        }
    }

    func didSuccessfullyLogin() {
        createEnrollment()
    }

    func createEnrollment() {
        UserProfileHelper.createEnrollement(course.id).onSuccess {
            self.course.is_enrolled = true
            CourseHelper.refreshCourses()
        }
    }

    @IBAction func unenroll(sender: UIButton) {
        // No need to check for login, cannot be enrolled without.

        UserProfileHelper.deleteEnrollement(course.id).onSuccess {
            self.course.is_enrolled = false
            CourseHelper.refreshCourses()
        }
    }

}
