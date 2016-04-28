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

    override func viewDidLoad() {
        courseTabBarController = self.tabBarController as! CourseTabBarController
        course = courseTabBarController.course

        customPreferredFocusedView = super.preferredFocusedView

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
        if let imageURL = course.image_url {
            ImageHelper.loadImageFromURL(imageURL, toImageView: courseImageView)
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

extension CourseDetailsViewController {

    @IBAction func enroll(sender: UIButton) {
        //TODO: Actually do something.
    }

    @IBAction func unenroll(sender: UIButton) {
        //TODO: Actually do something.
    }

}
