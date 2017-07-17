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
                showEnrollmentDialog()
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

        titleView.text = course.title

        if course.enrollment != nil {
            enrollmentButton.setTitle(NSLocalizedString("Enrollment options", comment: ""), for: UIControlState.normal)
            enrollmentButton.backgroundColor = UIColor.white
            enrollmentButton.tintColor = Brand.TintColor
        } else {
            enrollmentButton.setTitle(NSLocalizedString("Enroll", comment: ""), for: UIControlState.normal)
            enrollmentButton.backgroundColor = Brand.TintColor
            enrollmentButton.tintColor = UIColor.white
        }
        titleView.heroID = "course_title_" + course.id
        languageView.text = course.language_translated
        languageView.heroID = "course_language_" + course.id
        teacherView.text = course.teachers
        teacherView.textColor = Brand.TintColorSecond
        teacherView.heroID = "course_teacher_" + course.id
        imageView.heroID = "course_image_" + course.id

        dateView.text = DateLabelHelper.labelFor(startdate: course.start_at, enddate: course.end_at)
        imageView.sd_setImage(with: course.image_url)

        if let description = course.abstract {
            let markDown = try? MarkdownHelper.parse(description) // TODO: Error handling
            descriptionView.attributedText = markDown
        }
    }
    
    func showEnrollmentDialog() {
        let title = NSLocalizedString("Enroll in course?", comment: "Shown in confirmation dialog")
        let message = NSLocalizedString("You can always un-enroll.", comment: "Shown in confirmation dialog")
        let confirm = NSLocalizedString("Enroll", comment: "")
        let decline = NSLocalizedString("Cancel", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: confirm, style: .default, handler: { (action: UIAlertAction!) in
            EnrollmentHelper.createEnrollment(for: self.course)
                .flatMap { CourseHelper.refreshCourses() }
                .onSuccess { _ in
                    if let parent = self.parent as? CourseDecisionViewController {
                        parent.decideContent()
                    }
            }
        }))
        
        alert.addAction(UIAlertAction(title: decline, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    func showEnrollmentOptions() {
        let alert = UIAlertController(title: NSLocalizedString("Finished learning?", comment:""), message:  NSLocalizedString("You can mark a course as completed once you dont want to learn anymore in this course. This will clean up your dashboard. You may also unenroll from this course. This will make the course unaccessible for you. You can re-enroll later, then your progress will be restored.", comment: ""), preferredStyle: .actionSheet) // 1
        let completedAction = UIAlertAction(title: NSLocalizedString("Mark as completed", comment: ""), style: .default) { _ in
            EnrollmentHelper.markAsCompleted(self.course).onSuccess { _ in
                CourseHelper.refreshCourse(self.course)
            }
        }
        let unenrollAction = UIAlertAction(title: NSLocalizedString("Unenroll", comment: ""), style: .destructive) { _ in
            EnrollmentHelper.deleteEnrollment(for: self.course)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

        alert.addAction(completedAction)
        alert.addAction(unenrollAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
    

}
