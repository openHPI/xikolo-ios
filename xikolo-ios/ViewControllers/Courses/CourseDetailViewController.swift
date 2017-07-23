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
            showEnrollmentDialog()
        } else {
            performSegue(withIdentifier: "ShowLogin", sender: nil)
        }
    }
    var course: Course!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleView.text = course.title
 
        enrollmentButton.setTitle(NSLocalizedString("You are enrolled", comment: ""), for: [UIControlState.disabled])
        enrollmentButton.setTitle(NSLocalizedString("Enroll", comment: ""), for: [UIControlState.normal])
        if course.enrollment != nil {
            enrollmentButton.isEnabled = false
            enrollmentButton.backgroundColor = UIColor.white
            enrollmentButton.tintColor = Brand.TintColor
        }else{
            enrollmentButton.isEnabled = true
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

        if let description = course.abstract {//TODO: change back to course_description when API works
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

    @IBAction func unwindLogin(_ segue: UIStoryboardSegue) {
        segue.perform()
        if UserProfileHelper.isLoggedIn() {
            showEnrollmentDialog()
        }
    }

}
