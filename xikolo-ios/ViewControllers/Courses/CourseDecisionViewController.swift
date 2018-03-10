//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseDecisionViewController: UIViewController {

    enum CourseContent : Int {
        case learnings = 0
        case discussions = 1
        case courseDetails = 2
        case announcements = 3
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var dropdownIcon: UIImageView!

    var containerContentViewController: UIViewController?
    var course: Course!
    var content = CourseContent.learnings

    override func viewDidLoad() {
        super.viewDidLoad()

        self.decideContent()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(switchViewController),
                                               name: NotificationKeys.dropdownCourseContentKey,
                                               object: nil)

        self.course.notifyOnChange(self, updateHandler: {}) {
            let isVisible = self.isViewLoaded && self.view.window != nil
            self.navigationController?.popToRootViewController(animated: isVisible)
        }

        SpotlightHelper.setUserActivity(for: self.course)
        CrashlyticsHelper.shared.setObjectValue(self.course.id, forKey: "course_id")
    }

    @IBAction func unwindSegueToCourseContent(_ segue: UIStoryboardSegue) { }

    @IBAction func tapped(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowContentChoice", sender: sender)
    }

    func decideContent() {
        if (course.hasEnrollment) {
            updateContainerView(course.accessible ? .learnings : .courseDetails)
        } else {
            updateContainerView(.courseDetails)
        }
    }

    @objc func switchViewController(_ notification: Notification) {
        if let position = notification.userInfo?[NotificationKeys.dropdownCourseContentKey] as? Int, let content = CourseContent(rawValue: position) {
            updateContainerView(content)
        }
    }

    func updateContainerView(_ content: CourseContent) {
        // TODO: Animation?
        if let vc = containerContentViewController {
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            containerContentViewController = nil
        }


        let storyboard = UIStoryboard(name: "CourseContent", bundle: nil)
        switch content {
        case .learnings:
            let vc = storyboard.instantiateViewController(withIdentifier: "CourseItemListViewController").require(toHaveType: CourseItemListViewController.self)
            vc.course = course
            changeToViewController(vc)
            titleView.text = NSLocalizedString("course-content.view.learnings.title",
                                               comment: "title of learnings view of course view")
        case .discussions:
            let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController").require(toHaveType: WebViewController.self)
            if let slug = course.slug {
                vc.url = Routes.COURSES_URL + slug + "/pinboard"
            }
            changeToViewController(vc)
            titleView.text = NSLocalizedString("course-content.view.discussions.title",
                                               comment: "title of discussions view of course view")
        case .announcements:
            let announcementsStoryboard = UIStoryboard(name: "TabNews", bundle:nil)
            let vc = announcementsStoryboard.instantiateViewController(withIdentifier: "AnnouncementsTableViewController").require(toHaveType: AnnouncementsTableViewController.self)
            vc.course = course
            changeToViewController(vc)
            titleView.text = NSLocalizedString("course-content.view.announcements.title",
                                               comment: "title of announcements view of course view")
        case .courseDetails:
            let vc = storyboard.instantiateViewController(withIdentifier: "CourseDetailsViewController").require(toHaveType: CourseDetailViewController.self)
            vc.course = course
            changeToViewController(vc)
            titleView.text = NSLocalizedString("course-content.view.course-details.title",
                                               comment: "title of course details view of course view")
        }
        self.content = content

        // set width for new title view
        if let titleView = self.navigationItem.titleView, let text = self.titleView.text {
            let titleWidth = NSString(string: text).size(withAttributes: [NSAttributedStringKey.font : self.titleView.font]).width
            var frame = titleView.frame
            frame.size.width = titleWidth + self.dropdownIcon.frame.width + 2
            titleView.frame = frame
            titleView.setNeedsLayout()
        }
    }

    func changeToViewController(_ viewController: UIViewController) {
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        containerContentViewController = viewController
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
            break
        default:
            break
        }
    }

    @IBAction func shareCourse(_ sender: UIBarButtonItem) {
        let activityItems = ([self.course.title, self.course.url] as [Any?]).flatMap { $0 }
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        activityViewController.completionWithItemsHandler = { (activityType, completed, _, _) in
            let context: [String : String?] = [
                "service": activityType?.rawValue,
                "completed": String(describing: completed),
            ]
            TrackingHelper.createEvent(.share, resourceType: .course, resourceId: self.course.id, context: context)
        }
        self.present(activityViewController, animated: true)
    }

}

extension CourseDecisionViewController : UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }

    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navigationController.view.bounds
        navigationController.view.insertSubview(visualEffectView, at: 0)
        return navigationController
    }

}
