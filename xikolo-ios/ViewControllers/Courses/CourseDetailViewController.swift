//
//  CourseDetailViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 25.02.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit
import SDWebImage
import SimpleRoundedButton

class CourseDetailViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var languageView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var teacherView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var enrollmentButton: SimpleRoundedButton!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBAction func enroll(_ sender: UIButton) {
        if UserProfileHelper.isLoggedIn() {
            if !course.hasEnrollment {
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
        
        self.descriptionView.textContainerInset = UIEdgeInsets.zero
        self.descriptionView.textContainer.lineFragmentPadding = 0

        self.statusView.layer.cornerRadius = 4.0
        self.statusView.layer.masksToBounds = true
        self.statusView.backgroundColor = Brand.TintColorSecond

        self.updateView()
    }

    func updateView() {
        titleView.text = course.title
        languageView.text = course.language_translated
        teacherView.text = course.teachers
        teacherView.textColor = Brand.TintColorSecond

        dateView.text = DateLabelHelper.labelFor(startDate: course.startsAt, endDate: course.endsAt)
        imageView.sd_setImage(with: course.imageURL)

        if let description = course.abstract {
            let markDown = try? MarkdownHelper.parse(description) // TODO: Error handling
            descriptionView.attributedText = markDown
        }

        let buttonTitle: String
        if self.course.hasEnrollment {
            buttonTitle = NSLocalizedString("enrollment.button.enrolled.title", comment: "title of course enrollment button")
        } else {
            buttonTitle = NSLocalizedString("enrollment.button.not-enrolled.title", comment: "title of Course enrollment options button")
        }
        self.enrollmentButton.setTitle(buttonTitle, for: .normal)
        self.enrollmentButton.backgroundColor = self.course.hasEnrollment ? Brand.TintColor.withAlphaComponent(0.2) : Brand.TintColor
        self.enrollmentButton.tintColor = self.course.hasEnrollment ? UIColor.darkGray : UIColor.white

        if self.course.hasEnrollment {
            self.statusView.isHidden = false
            self.statusLabel.text = NSLocalizedString("course-cell.status.enrolled", comment: "status 'enrolled' of a course")
        } else {
            self.statusView.isHidden = true
        }
    }

    func createEnrollment() {
        self.enrollmentButton.startAnimating()
        EnrollmentHelper.createEnrollment(for: self.course).onComplete { _ in
            self.enrollmentButton.stopAnimating()
        }.onSuccess { _ in
            if let parent = self.parent as? CourseDecisionViewController {
                parent.decideContent()
            }
            CourseHelper.syncCourse(self.course)
        }.onFailure { _ in
            self.enrollmentButton.shake()
        }
    }

    func showEnrollmentOptions() {
        let alertTitle = NSLocalizedString("enrollment.options-alert.title", comment:"title of enrollment options alert")
        let alertMessage = NSLocalizedString("enrollment.options-alert.message", comment: "message of enrollment alert")
        let alert = UIAlertController(title: alertTitle, message:  alertMessage, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = self.enrollmentButton
        alert.popoverPresentationController?.sourceRect = self.enrollmentButton.bounds
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up.union(.down)

        let completedActionTitle = NSLocalizedString("enrollment.options-alert.mask-as-completed-action.title",
                                                     comment: "title for 'mask as completed' action")
        let completedAction = UIAlertAction(title: completedActionTitle, style: .default) { _ in
            self.enrollmentButton.startAnimating()
            EnrollmentHelper.markAsCompleted(self.course).onComplete { _ in
                self.enrollmentButton.stopAnimating()
            }.onSuccess { _ in
                DispatchQueue.main.async {
                    self.updateView()
                }
                CourseHelper.syncCourse(self.course)
            }.onFailure { _ in
                self.enrollmentButton.shake()
            }

        }
        let unenrollActionTitle = NSLocalizedString("enrollment.options-alert.unenroll-action.title",
                                                    comment: "title for unenroll action")
        let unenrollAction = UIAlertAction(title: unenrollActionTitle, style: .destructive) { _ in
            self.enrollmentButton.startAnimating()
            EnrollmentHelper.delete(self.course.enrollment).onComplete { _ in
                self.enrollmentButton.stopAnimating()
            }.onSuccess { _ in
                DispatchQueue.main.async {
                    self.updateView()
                }
                CourseHelper.syncCourse(self.course)
            }.onFailure { _ in
                self.enrollmentButton.shake()
            }
        }

        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)

        alert.addAction(completedAction)
        alert.addAction(unenrollAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
    

}
