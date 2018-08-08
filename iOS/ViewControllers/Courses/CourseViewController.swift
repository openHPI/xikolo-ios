//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleView: UILabel!

    private var courseAreaViewController: UIViewController?
    private var courseAreaListViewController: CourseAreaListViewController? {
        didSet {
            self.courseAreaListViewController?.delegate = self
        }
    }

    private var courseObserver: ManagedObjectObserver?

    var content: CourseArea?
    var course: Course! {
        didSet {
            self.updateView()
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

        self.decideContent()

        SpotlightHelper.shared.setUserActivity(for: self.course)
        CrashlyticsHelper.shared.setObjectValue(self.course.id, forKey: "course_id")
    }

    private func updateView() {
        self.titleView.text = self.course.title

        if let titleView = self.navigationItem.titleView, let text = self.titleView.text {
            let titleWidth = NSString(string: text).size(withAttributes: [NSAttributedStringKey.font: self.titleView.font]).width
            var frame = titleView.frame
            frame.size.width = titleWidth + 2
            titleView.frame = frame
            titleView.setNeedsLayout()
        }
    }

    private func closeCourse() {
        let courseNavigationController = self.navigationController as? CourseNavigationController
        courseNavigationController?.closeCourse()
    }

    @IBAction func tappedCloseButton(_ sender: Any) {
        self.closeCourse()
    }

    func decideContent(newlyEnrolled: Bool = false) {
        if !self.course.hasEnrollment {
            self.content = .courseDetails
        } else if newlyEnrolled || self.content == nil {
            self.content = course.accessible ? .learnings : .courseDetails
        }

        let content = self.content.require(hint: "This should never occur. Invalid use of course view controller")
        self.courseAreaListViewController?.refresh(animated: false)
        self.updateContainerView(to: content)
    }

    func updateContainerView(to content: CourseArea) {
        if let viewController = self.courseAreaViewController {
            viewController.willMove(toParentViewController: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
            self.courseAreaViewController = nil
        }

        guard let courseAreaViewController = content.viewController else { return }
        courseAreaViewController.configure(for: course)

        self.containerView.addSubview(courseAreaViewController.view)
        courseAreaViewController.view.frame = self.containerView.bounds
        self.addChildViewController(courseAreaViewController)
        courseAreaViewController.didMove(toParentViewController: self)
        self.courseAreaViewController = courseAreaViewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let courseAreaListViewController = segue.destination as? CourseAreaListViewController {
            self.courseAreaListViewController = courseAreaListViewController
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
            TrackingHelper.shared.createEvent(.shareCourse, resourceType: .course, resourceId: self.course.id, context: context)
        }

        self.present(activityViewController, animated: true)
    }

}

extension CourseViewController: CourseAreaListViewControllerDelegate {

    var accessibleContent: [CourseArea] {
        if self.course.hasEnrollment && self.course.accessible {
            return CourseArea.orderedValues
        } else {
            return CourseArea.orderedValues.filter { $0.acessibleWithoutEnrollment }
        }
    }

    var selectedContent: CourseArea? {
        return self.content
    }

    func change(to content: CourseArea) {
        self.content = content
        self.updateContainerView(to: content)
    }

}
