//
//  CourseDecisionViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit


class CourseDecisionViewController: UIViewController {

    enum CourseContent : Int {
        case learnings = 0
        case discussions = 1
        case courseDetails = 2
    }

    @IBOutlet weak var enrollButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleView: UILabel!

    var containerContentViewController: UIViewController?
    var course: Course!
    var content = CourseContent.learnings

    deinit {
        NotificationCenter.default.removeObserver(self);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        decideContent()
        NotificationCenter.default.addObserver(self, selector: #selector(switchViewController), name: NotificationKeys.dropdownCourseContentKey, object: nil)
    }

    @IBAction func enroll(_ sender: UIBarButtonItem) {
        if UserProfileHelper.isLoggedIn() {
            showEnrollmentDialog()
        } else {
            performSegue(withIdentifier: "ShowLogin", sender: nil)
        }

    }

    @IBAction func unwindSegueToCourseContent(_ segue: UIStoryboardSegue) { }

    func decideContent() {
        if(course.enrollment != nil) {
            navigationItem.rightBarButtonItem = nil
            updateContainerView(course.accessible ? .learnings : .courseDetails)
        } else {
            updateContainerView(.courseDetails)
        }
    }

    func switchViewController(_ notification: Notification) {
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

        let storyboard = UIStoryboard(name: "TabCourses", bundle: nil)
        switch content {
        case .learnings:
            let vc = storyboard.instantiateViewController(withIdentifier: "CourseContentTableViewController") as! CourseContentTableViewController
            vc.course = course
            changeToViewController(vc)
            titleView.text = NSLocalizedString("Learnings", comment: "")
        case .discussions:
            let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            if let slug = course.slug {
                vc.url = Routes.COURSES_URL + slug + "/pinboard"
            }
            changeToViewController(vc)
            titleView.text = NSLocalizedString("Discussions", comment: "")
        case .courseDetails:
            let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            if let slug = course.slug {
                vc.url = Routes.COURSES_URL + slug
            }
            changeToViewController(vc)
            titleView.text = NSLocalizedString("Course Details", comment: "")
        }
        self.content = content
    }

    func changeToViewController(_ viewController: UIViewController) {
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        containerContentViewController = viewController
    }

    func showEnrollmentDialog() {
        let title = NSLocalizedString("Enroll in course?", comment: "Shown in confirmation dialog")
        let message = NSLocalizedString("You can always un-enroll.", comment: "Shown in confirmation dialog")
        let confirm = NSLocalizedString("Enroll", comment: "")
        let decline = NSLocalizedString("Cancel", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: confirm, style: .default, handler: { (action: UIAlertAction!) in
            UserProfileHelper.createEnrollment(self.course.id)
                .flatMap { CourseHelper.refreshCourses() }
                .onSuccess { _ in
                    self.decideContent()
                }
        }))

        alert.addAction(UIAlertAction(title: decline, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowContentChoice"?:
            let dropdownViewController = segue.destination as! DropdownViewController
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
