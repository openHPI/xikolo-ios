//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import Binge
import BrightFutures
import Common
import SDWebImage
import UIKit

class CourseDetailsViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var teaserView: UIView!
    @IBOutlet private weak var teaserImageView: UIImageView!
    @IBOutlet private weak var languageView: UILabel!
    @IBOutlet private weak var dateView: UILabel!
    @IBOutlet private weak var teacherView: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var enrollmentButton: LoadingButton!
    @IBOutlet private weak var enrollmentOptionsButton: UIButton!

    private weak var delegate: CourseAreaViewControllerDelegate?
    private var courseObserver: ManagedObjectObserver?

    var course: Course! {
        didSet {
            self.courseObserver = ManagedObjectObserver(object: self.course) { [weak self] type in
                guard type == .update else { return }
                DispatchQueue.main.async {
                    self?.updateView(animated: true)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.teaserView.isHidden = true
        self.teaserView.layer.roundCorners(for: .default)
        self.teaserImageView.backgroundColor = Brand.default.colors.secondary

        self.teacherView.textColor = Brand.default.colors.secondary
        self.teacherView.isHidden = !Brand.default.features.showCourseTeachers

        self.enrollmentButton.layer.roundCorners(for: .default)

        self.descriptionView.textContainerInset = UIEdgeInsets.zero
        self.descriptionView.textContainer.lineFragmentPadding = 0
        self.descriptionView.delegate = self

        self.updateView()

        self.addRefreshControl()
        self.refresh()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)

        self.scrollView.delegate = self

        CourseHelper.syncCourse(course)
    }

    private func updateView(animated: Bool = false) {
        self.languageView.text = self.course.localizedLanguage
        self.teacherView.text = self.course.teachers

        self.dateView.text = DateLabelHelper.labelFor(startDate: self.course.startsAt, endDate: self.course.endsAt)
        self.teaserImageView.sd_setImage(with: self.course.imageURL)

        let animationDuration = animated ? 0.25 : 0
        // swiftlint:disable:next trailing_closure
        UIView.transition(with: self.teaserView, duration: animationDuration, options: .curveEaseInOut, animations: {
            self.teaserView.isHidden = self.course.teaserStream?.hlsURL == nil
        })

        let markdown = self.course.courseDescription ?? self.course.abstract
        self.descriptionView.setMarkdownWithImages(from: markdown)

        self.refreshEnrollButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.courseDetailsViewController.showLogin(segue: segue) {
            let loginViewController = typedInfo.destination.viewControllers.first as? LoginViewController
            loginViewController?.delegate = self
        }
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
            self.enrollmentButton.backgroundColor = Brand.default.colors.primaryLight
            self.enrollmentButton.tintColor = ColorCompatibility.secondaryLabel
            self.enrollmentOptionsButton.tintColor = ColorCompatibility.secondaryLabel
        } else if ReachabilityHelper.hasConnection {
            self.enrollmentButton.backgroundColor = Brand.default.colors.primary
            self.enrollmentButton.tintColor = ColorCompatibility.systemBackground
            self.enrollmentOptionsButton.tintColor = ColorCompatibility.systemBackground
        } else {
            self.enrollmentButton.backgroundColor = ColorCompatibility.secondarySystemBackground
            self.enrollmentButton.tintColor = ColorCompatibility.secondaryLabel
            self.enrollmentOptionsButton.tintColor = ColorCompatibility.secondaryLabel
        }

        self.enrollmentButton.isEnabled = self.course.hasEnrollment || ReachabilityHelper.hasConnection
        self.enrollmentOptionsButton.isHidden = !self.course.hasEnrollment
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
            self.performSegue(withIdentifier: R.segue.courseDetailsViewController.showLogin, sender: nil)
        }
    }

    @IBAction private func playTeaser() {
        guard let url = self.course.teaserStream?.hlsURL else { return }

        let playerViewController = BingePlayerViewController()
        playerViewController.delegate = self
        playerViewController.tintColor = Brand.default.colors.window
        playerViewController.initiallyShowControls = false
        playerViewController.modalPresentationStyle = .fullScreen

        if UserDefaults.standard.playbackRate > 0 {
            playerViewController.playbackRate = UserDefaults.standard.playbackRate
        }

        playerViewController.asset = AVURLAsset(url: url)

        self.present(playerViewController, animated: trueUnlessReduceMotionEnabled) {
            playerViewController.startPlayback()
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
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
                AnnouncementHelper.syncAnnouncements(for: course)
            }

            DispatchQueue.main.async {
                self?.refreshEnrollButton()
                self?.delegate?.enrollmentStateDidChange(whenNewlyCreated: newlyCreated)
            }
        }.onFailure { [weak self] error in
            ErrorManager.shared.report(error)
            self?.enrollmentButton.shake()
        }
    }

}

extension CourseDetailsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidScroll(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidEndDecelerating(scrollView)
    }

}

extension CourseDetailsViewController: RefreshableViewController {

    var refreshableScrollView: UIScrollView {
        return self.scrollView
    }

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseHelper.syncCourse(self.course).asVoid()
    }

}

extension CourseDetailsViewController: LoginDelegate {

    func didSuccessfullyLogin() {
        self.createEnrollment()
    }

}

extension CourseDetailsViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let appNavigator = self.appNavigator else { return false }
        return !appNavigator.handle(url: URL, on: self)
    }

}

extension CourseDetailsViewController: BingePlayerDelegate {

    func didChangePlaybackRate(from oldRate: Float, to newRate: Float) {
        UserDefaults.standard.playbackRate = newRate
    }

}

extension CourseDetailsViewController: CourseAreaViewController {

    var area: CourseArea {
        return .courseDetails
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        assert(area == self.area)
        self.delegate = delegate
        self.course = course
    }

}
