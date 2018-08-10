//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import SDWebImage
import SimpleRoundedButton
import UIKit

class CourseDetailViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var languageView: UILabel!
    @IBOutlet private weak var dateView: UILabel!
    @IBOutlet private weak var teacherView: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var enrollmentButton: SimpleRoundedButton!
    @IBOutlet private weak var statusView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!

    private weak var delegate: CourseAreaViewControllerDelegate?
    private var courseObserver: ManagedObjectObserver?

    var course: Course! {
        didSet {
            self.courseObserver = ManagedObjectObserver(object: self.course) { [weak self] type in
                guard type == .update else { return }
                DispatchQueue.main.async {
                    self?.updateView()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.backgroundColor = Brand.default.colors.secondary

        self.descriptionView.textContainerInset = UIEdgeInsets.zero
        self.descriptionView.textContainer.lineFragmentPadding = 0
        self.descriptionView.delegate = self

        self.statusView.layer.cornerRadius = 4.0
        self.statusView.layer.masksToBounds = true
        self.statusView.backgroundColor = Brand.default.colors.secondary

        self.updateView()
        self.updateImageViewAppearence()

        self.setupRefreshControl()
        self.refresh()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            self.updateImageViewAppearence()
        }
    }

    private func updateView() {
        self.titleView.text = self.course.title
        self.languageView.text = self.course.localizedLanguage
        self.teacherView.text = self.course.teachers
        self.teacherView.textColor = Brand.default.colors.secondary

        self.dateView.text = DateLabelHelper.labelFor(startDate: self.course.startsAt, endDate: self.course.endsAt)
        self.imageView.sd_setImage(with: self.course.imageURL)

        if let description = self.course.courseDescription ?? self.course.abstract {
            MarkdownHelper.attributedString(for: description).onSuccess(DispatchQueue.main.context) { attributedString in
                self.descriptionView.attributedText = attributedString
            }
        }

        self.refreshEnrollmentViews()
    }

    private func updateImageViewAppearence() {
        let showEdgeToEdge = self.traitCollection.horizontalSizeClass != .regular
        self.imageView.layer.cornerRadius = showEdgeToEdge ? 0 : 6.0
        self.imageView.layer.masksToBounds = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.courseDetailViewController.showLogin(segue: segue) {
            let loginViewController = typedInfo.destination.viewControllers.first as? LoginViewController
            loginViewController?.delegate = self
        }
    }

    private func refreshEnrollmentViews() {
        self.refreshEnrollButton()
        self.refreshStatusView()
    }

    private func refreshEnrollButton() {
        let buttonTitle: String
        if self.course.hasEnrollment {
            buttonTitle = NSLocalizedString("enrollment.button.enrolled.title", comment: "title of course enrollment button")
        } else {
            buttonTitle = NSLocalizedString("enrollment.button.not-enrolled.title", comment: "title of Course enrollment options button")
        }

        self.enrollmentButton.setTitle(buttonTitle, for: .normal)

        if self.course.hasEnrollment {
            self.enrollmentButton.backgroundColor = Brand.default.colors.primary.withAlphaComponent(0.2)
            self.enrollmentButton.tintColor = UIColor.darkGray
        } else if ReachabilityHelper.connection != .none {
            self.enrollmentButton.backgroundColor = Brand.default.colors.primary
            self.enrollmentButton.tintColor = UIColor.white
        } else {
            self.enrollmentButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            self.enrollmentButton.tintColor = UIColor.darkText
        }

        self.enrollmentButton.isEnabled = self.course.hasEnrollment || ReachabilityHelper.connection != .none
    }

    private func refreshStatusView() {
        if self.course.hasEnrollment {
            self.statusView.isHidden = false
            self.statusLabel.text = NSLocalizedString("course-cell.status.enrolled", comment: "status 'enrolled' of a course")
        } else {
            self.statusView.isHidden = true
        }
    }

    @objc func reachabilityChanged() {
        self.refreshEnrollButton()
    }

    @IBAction func enroll(_ sender: UIButton) {
        if UserProfileHelper.shared.isLoggedIn {
            if !course.hasEnrollment {
                self.createEnrollment()
            } else {
                self.showEnrollmentOptions()
            }
        } else {
            self.performSegue(withIdentifier: R.segue.courseDetailViewController.showLogin, sender: nil)
        }
    }

    private func createEnrollment() {
        self.actOnEnrollmentChange(whenNewlyCreated: true) {
            EnrollmentHelper.createEnrollment(for: self.course)
        }
    }

    private func showEnrollmentOptions() {
        let alertTitle = NSLocalizedString("enrollment.options-alert.title", comment: "title of enrollment options alert")
        let alertMessage = NSLocalizedString("enrollment.options-alert.message", comment: "message of enrollment alert")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = self.enrollmentButton
        alert.popoverPresentationController?.sourceRect = self.enrollmentButton.bounds
        alert.popoverPresentationController?.permittedArrowDirections = [.up, .down]

        let completedActionTitle = NSLocalizedString("enrollment.options-alert.mask-as-completed-action.title",
                                                     comment: "title for 'mask as completed' action")
        let completedAction = UIAlertAction(title: completedActionTitle, style: .default) { _ in
            self.actOnEnrollmentChange {
                EnrollmentHelper.markAsCompleted(self.course)
            }
        }

        let unenrollActionTitle = NSLocalizedString("enrollment.options-alert.unenroll-action.title",
                                                    comment: "title for unenroll action")
        let unenrollAction = UIAlertAction(title: unenrollActionTitle, style: .destructive) { _ in
            self.actOnEnrollmentChange {
                EnrollmentHelper.delete(self.course.enrollment)
            }
        }

        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)

        alert.addAction(completedAction)
        alert.addAction(unenrollAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }

    private func actOnEnrollmentChange(whenNewlyCreated newlyCreated: Bool = false, for task: () -> Future<Void, XikoloError>) {
        self.enrollmentButton.startAnimating()
        task().onComplete { _ in
            self.enrollmentButton.stopAnimating()
        }.onSuccess { _ in
            if newlyCreated {
                CourseHelper.syncCourse(self.course)
                CourseDateHelper.syncCourseDates(for: self.course)
            }

            DispatchQueue.main.async {
                self.refreshEnrollmentViews()
                self.delegate?.enrollmentStateDidChange()
            }
        }.onFailure { _ in
            self.enrollmentButton.shake()
        }
    }

}

extension CourseDetailViewController: RefreshableViewController {

    var refreshableScrollView: UIScrollView {
        return self.scrollView
    }

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseHelper.syncCourse(self.course).asVoid()
    }

}

extension CourseDetailViewController: LoginDelegate {

    func didSuccessfullyLogin() {
        self.createEnrollment()
    }

}

extension CourseDetailViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return !AppNavigator.handle(URL, on: self)
    }

}

extension CourseDetailViewController: CourseAreaViewController {

    func configure(for course: Course, delegate: CourseAreaViewControllerDelegate) {
        self.delegate = delegate
        self.course = course
    }

}
