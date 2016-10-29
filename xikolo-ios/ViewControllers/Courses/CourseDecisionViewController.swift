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
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    @IBAction func enroll(sender: UIBarButtonItem) {
        if UserProfileHelper.isLoggedIn() {
            UserProfileHelper.createEnrollement(course.id)
                .flatMap { CourseHelper.refreshCourses() }
                .onSuccess { _ in
                    self.decideContent()
            }
        } else {
            performSegueWithIdentifier("ShowLoginForEnroll", sender: nil)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        decideContent()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(switchViewController), name: NotificationKeys.dropdownCourseContentKey, object: nil)
    }

    func decideContent() {
        if(course.enrollment != nil) {
            navigationItem.rightBarButtonItem = nil
        }
        updateContainerView(course.accessible ? .learnings : .courseDetails)
    }

    func switchViewController(notification: NSNotification) {
        let userInfo : [String:Int] = notification.userInfo as! [String:Int]
        if let position = userInfo[NotificationKeys.dropdownCourseContentKey], content = CourseContent(rawValue: position) {
            updateContainerView(content)
        }
    }

    func updateContainerView(content: CourseContent) {
        // TODO: Animation?
        if let vc = containerContentViewController {
            vc.willMoveToParentViewController(nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            containerContentViewController = nil
        }

        let storyboard = UIStoryboard(name: "TabCourses", bundle: nil)
        switch content {
        case .learnings:
            let vc = storyboard.instantiateViewControllerWithIdentifier("CourseContentTableViewController") as! CourseContentTableViewController
            vc.course = course
            changeToViewController(vc)
            titleView.text = NSLocalizedString("Learnings", comment: "")
        case .discussions:
            let vc = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
            if let slug = course.slug {
                vc.url = Routes.COURSES_URL + slug + "/pinboard"
            }
            changeToViewController(vc)
            titleView.text = NSLocalizedString("Discussions", comment: "")
        case .courseDetails:
            let vc = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
            if let slug = course.slug {
                vc.url = Routes.COURSES_URL + slug
            }
            changeToViewController(vc)
            titleView.text = NSLocalizedString("Course Details", comment: "")
        }
        self.content = content
    }

    func changeToViewController(viewController: UIViewController) {
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        addChildViewController(viewController)
        viewController.didMoveToParentViewController(self)
        containerContentViewController = viewController
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "ShowContentChoice"?:
            let dropdownViewController = segue.destinationViewController as! DropdownViewController
            if let ppc = dropdownViewController.popoverPresentationController {
                if let view = navigationItem.titleView {
                    ppc.sourceView = view
                    ppc.sourceRect = view.bounds
                }

                dropdownViewController.course = course
                let minimumSize = dropdownViewController.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                dropdownViewController.preferredContentSize = minimumSize
                ppc.delegate = self
            }
            break
        default:
            break
        }
    }

    @IBAction func unwindSegueToCourseContent(segue: UIStoryboardSegue) { }

}

extension CourseDecisionViewController : UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }

    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        visualEffectView.frame = navigationController.view.bounds
        navigationController.view.insertSubview(visualEffectView, atIndex: 0)
        return navigationController
    }

}
