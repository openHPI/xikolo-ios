//
//  CourseDetailViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 25.02.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit
import Hero
import SDWebImage


class CourseDetailViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var languageView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var teacherView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var enrollmentButton: UIButton!
    
    @IBAction func enroll(_ sender: UIButton) {
        if UserProfileHelper.isLoggedIn() {
            if course.enrollment == nil {
                createEnrollment()
            } else {
                showEnrollmentOptions()
            }
        } else {
            performSegue(withIdentifier: "ShowLogin", sender: nil)
        }
    }
    var course: Course!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(setEnrolledState), name: NotificationKeys.createdEnrollmentKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setUnenrolledState), name: NotificationKeys.deletedEnrollmentKey, object: nil)

        descriptionView.textContainerInset = UIEdgeInsets.zero
        descriptionView.textContainer.lineFragmentPadding = 0

        titleView.text = course.title
        titleView.heroID = "course_title_" + course.id
        languageView.text = course.language_translated
        languageView.heroID = "course_language_" + course.id
        teacherView.text = course.teachers
        teacherView.textColor = Brand.TintColorSecond
        teacherView.heroID = "course_teacher_" + course.id
        imageView.heroID = "course_image_" + course.id

        dateView.text = DateLabelHelper.labelFor(startdate: course.startsAt, enddate: course.endsAt)
        imageView.sd_setImage(with: course.imageURL)

        if let description = course.abstract {
            let markDown = try? MarkdownHelper.parse(description) // TODO: Error handling
            descriptionView.attributedText = markDown
        }

        if course.enrollment != nil {
            setEnrolledState()
        } else {
            setUnenrolledState()
        }
    }

    @objc func setEnrolledState() {
        DispatchQueue.main.async {
            let buttonTitle = NSLocalizedString("enrollment.button.enrolled.title",
                                                comment: "title of course enrollment button")
            self.enrollmentButton.setTitle(buttonTitle, for: UIControlState.normal)
            self.enrollmentButton.backgroundColor = Brand.TintColor.withAlphaComponent(0.2)
            self.enrollmentButton.tintColor = UIColor.darkGray
        }
    }

    @objc func setUnenrolledState() {
        DispatchQueue.main.async {
            let buttonTitle = NSLocalizedString("enrollment.button.not-enrolled.title",
                                                comment: "title of Course enrollment options button")
            self.enrollmentButton.setTitle(buttonTitle, for: UIControlState.normal)
            self.enrollmentButton.backgroundColor = Brand.TintColor
            self.enrollmentButton.tintColor = UIColor.white
        }
    }
    
    func createEnrollment() {
        EnrollmentHelper.createEnrollment(for: self.course).flatMap {
            CourseHelper.syncAllCourses()
        }.onSuccess { _ in
            if let parent = self.parent as? CourseDecisionViewController {
                parent.decideContent()
            }
        }
    }

    func showEnrollmentOptions() {
        let alertTitle = NSLocalizedString("enrollment.options-alert.title", comment:"title of enrollment options alert")
        let alertMessage = NSLocalizedString("enrollment.options-alert.message", comment: "message of enrollment alert")
        let alert = UIAlertController(title: alertTitle, message:  alertMessage, preferredStyle: .actionSheet)

        let completedActionTitle = NSLocalizedString("enrollment.options-alert.mask-as-completed-action.title",
                                                     comment: "title for 'mask as completed' action")
        let completedAction = UIAlertAction(title: completedActionTitle, style: .default) { _ in
            EnrollmentHelper.markAsCompleted(self.course).onSuccess { _ in
                CourseHelper.syncCourse(self.course)
            }
        }
        let unenrollActionTitle = NSLocalizedString("enrollment.options-alert.unenroll-action.title",
                                                    comment: "title for unenroll action")
        let unenrollAction = UIAlertAction(title: unenrollActionTitle, style: .destructive) { _ in
            EnrollmentHelper.delete(self.course.enrollment!)
        }

        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)

        alert.addAction(completedAction)
        alert.addAction(unenrollAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
    

}
