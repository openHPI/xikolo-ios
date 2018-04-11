//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController {

    enum CourseContent: Int {
        case learnings = 0
        case discussions = 1
        case courseDetails = 2
        case announcements = 3
    }

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var dropdownIcon: UIImageView!

    var containerContentViewController: UIViewController?
    var course: Course!
    var content: CourseContent?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.decideContent()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(switchViewController),
                                               name: NotificationKeys.dropdownCourseContentKey,
                                               object: nil)

        self.course.notifyOnChange(self, updateHandler: {}, deleteHandler: { [weak self] in
            self?.closeCourse()
        })

        SpotlightHelper.setUserActivity(for: self.course)
        CrashlyticsHelper.shared.setObjectValue(self.course.id, forKey: "course_id")
    }

    private func closeCourse() {
        let courseNavigationController = self.navigationController as? CourseNavigationController
        courseNavigationController?.closeCourse()
    }

    @IBAction func unwindSegueToCourseContent(_ segue: UIStoryboardSegue) { }

    @IBAction func tapped(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowContentChoice", sender: sender)
    }

    @IBAction func tappedCloseButton(_ sender: Any) {
        self.closeCourse()
    }

    func decideContent() {
        if course.hasEnrollment {
            if let content = self.content { // it already got set from outside
                self.updateContainerView(content)
            } else {
                self.updateContainerView(course.accessible ? .learnings : .courseDetails)
            }
        } else {
            self.updateContainerView(.courseDetails)
        }
    }

    @objc func switchViewController(_ notification: Notification) {
        if let position = notification.userInfo?[NotificationKeys.dropdownCourseContentKey] as? Int, let content = CourseContent(rawValue: position) {
            updateContainerView(content)
        }
    }

    func updateContainerView(_ content: CourseContent) {
        if let viewController = self.containerContentViewController {
            viewController.willMove(toParentViewController: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
            self.containerContentViewController = nil
        }

        switch content {
        case .learnings:
            let storyboard = UIStoryboard(name: "CourseLearnings", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController().require(hint: "Initial view controller required")
            let viewController = initialViewController.require(toHaveType: CourseItemListViewController.self)
            viewController.course = course
            self.changeToViewController(viewController)
            self.titleView.text = NSLocalizedString("course-content.view.learnings.title", comment: "title of learnings view of course view")
        case .discussions:
            let storyboard = UIStoryboard(name: "WebViewController", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController().require(hint: "Initial view controller required")
            let viewController = initialViewController.require(toHaveType: WebViewController.self)
            if let slug = course.slug {
                viewController.url = Routes.COURSES_URL + slug + "/pinboard"
            }

            self.changeToViewController(viewController)
            self.titleView.text = NSLocalizedString("course-content.view.discussions.title", comment: "title of discussions view of course view")
        case .announcements:
            let announcementsStoryboard = UIStoryboard(name: "TabNews", bundle: nil)
            let loadedViewController = announcementsStoryboard.instantiateViewController(withIdentifier: "AnnouncementsTableViewController")
            let viewController = loadedViewController.require(toHaveType: AnnouncementsTableViewController.self)
            viewController.course = course
            self.changeToViewController(viewController)
            self.titleView.text = NSLocalizedString("course-content.view.announcements.title", comment: "title of announcements view of course view")
        case .courseDetails:
            let storyboard = UIStoryboard(name: "CourseDetails", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController().require(hint: "Initial view controller required")
            let viewController = initialViewController.require(toHaveType: CourseDetailViewController.self)
            viewController.course = course
            self.changeToViewController(viewController)
            self.titleView.text = NSLocalizedString("course-content.view.course-details.title", comment: "title of course details view of course view")
        }

        self.content = content

        // set width for new title view
        if let titleView = self.navigationItem.titleView, let text = self.titleView.text {
            let titleWidth = NSString(string: text).size(withAttributes: [NSAttributedStringKey.font: self.titleView.font]).width
            var frame = titleView.frame
            frame.size.width = titleWidth + self.dropdownIcon.frame.width + 2
            titleView.frame = frame
            titleView.setNeedsLayout()
        }
    }

    func changeToViewController(_ viewController: UIViewController) {
        self.containerView.addSubview(viewController.view)
        viewController.view.frame = self.containerView.bounds
        self.addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        self.containerContentViewController = viewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowContentChoice"?:
            let dropdownViewController = segue.destination.require(toHaveType: DropdownViewController.self)
            if let ppc = dropdownViewController.popoverPresentationController {
                if let view = navigationItem.titleView {
                    ppc.sourceView = view
                    ppc.sourceRect = view.bounds
                }

                dropdownViewController.course = course
                let minimumSize = dropdownViewController.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                dropdownViewController.preferredContentSize = minimumSize
                ppc.delegate = self
            }
        default:
            break
        }
    }

    @IBAction func shareCourse(_ sender: UIBarButtonItem) {
        let activityItems = ([self.course.title, self.course.url] as [Any?]).compactMap { $0 }
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            let context: [String: String?] = [
                "service": activityType?.rawValue,
                "completed": String(describing: completed),
            ]
            TrackingHelper.createEvent(.share, resourceType: .course, resourceId: self.course.id, context: context)
        }

        self.present(activityViewController, animated: true)
    }

}

extension CourseViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }

    func presentationController(_ controller: UIPresentationController,
                                viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navigationController.view.bounds
        navigationController.view.insertSubview(visualEffectView, at: 0)
        return navigationController
    }

}
