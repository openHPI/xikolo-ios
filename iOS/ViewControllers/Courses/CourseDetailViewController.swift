//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVKit
import BrightFutures
import Common
import CoreGraphics
import SDWebImage
import UIKit

class CourseDetailViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var languageView: UILabel!
    @IBOutlet private weak var dateView: UILabel!
    @IBOutlet private weak var teacherView: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var enrollmentButton: LoadingButton!
    @IBOutlet private weak var statusView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var playView: UIVisualEffectView!
    @IBOutlet private weak var playTeaserButton: UIButton!

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

    @IBAction func playTeaser(_ sender: Any) {
        guard let url = course.teaserStream?.hlsURL else { return }
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
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
        self.statusLabel.backgroundColor = Brand.default.colors.secondary

        self.updateView()
        self.updateImageViewAppearence()

        self.addRefreshControl()
        self.refresh()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)

        CourseHelper.syncCourse(course).onSuccess { _ in
            
        }
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
        self.teacherView.isHidden = !Brand.default.features.showCourseTeachers

        self.dateView.text = DateLabelHelper.labelFor(startDate: self.course.startsAt, endDate: self.course.endsAt)
        self.imageView.sd_setImage(with: self.course.imageURL)
//        let origin = self.imageView.frame - self.playView.frame
//        let region = CGRect(origin: , size: self.playView.frame +
//        print(self.imageView.image?.averageColor())

        if course.teaserStream?.hlsURL != nil {
            if self.playView.isHidden {
//                self.playView.alpha = 0
//                self.playView.isHidden = false

                UIView.transition(with: self.playView, duration: 0.25, options: .curveEaseInOut, animations: {
                    self.playView.isHidden = false
                } )
//                UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
//                    self.playView.alpha = 1
//                }, completion: nil)
            }
        } else {
            self.playView.isHidden = true
        }

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

    @IBAction private func enroll(_ sender: UIButton) {
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
            self.actOnEnrollmentChange(whenNewlyCreated: false) {
                EnrollmentHelper.markAsCompleted(self.course)
            }
        }

        let unenrollActionTitle = NSLocalizedString("enrollment.options-alert.unenroll-action.title",
                                                    comment: "title for unenroll action")
        let unenrollAction = UIAlertAction(title: unenrollActionTitle, style: .destructive) { _ in
            self.actOnEnrollmentChange(whenNewlyCreated: false) {
                EnrollmentHelper.delete(self.course.enrollment)
            }
        }

        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)

        alert.addAction(completedAction)
        alert.addAction(unenrollAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

    private func actOnEnrollmentChange(whenNewlyCreated newlyCreated: Bool, for task: () -> Future<Void, XikoloError>) {
        self.enrollmentButton.startAnimation()
        let dispatchTime = 500.milliseconds.fromNow
        task().earliest(at: dispatchTime).onComplete { [weak self] _ in
            self?.enrollmentButton.stopAnimation()
        }.onSuccess { [weak self] _ in
            if let course = self?.course {
                CourseHelper.syncCourse(course)
                CourseDateHelper.syncCourseDates(for: course)
                AnnouncementHelper.shared.syncAnnouncements(for: course)
            }

            DispatchQueue.main.async {
                self?.refreshEnrollmentViews()
                self?.delegate?.enrollmentStateDidChange(whenNewlyCreated: newlyCreated)
            }
        }.onFailure { [weak self] error in
            ErrorManager.shared.report(error)
            self?.enrollmentButton.shake()
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
        return !AppNavigator.handle(url: URL, on: self)
    }

}

extension CourseDetailViewController: CourseAreaViewController {

    var area: CourseArea {
        return .courseDetails
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        assert(area == self.area)
        self.delegate = delegate
        self.course = course
    }

}
