//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleView: UILabel!

    private var courseContentListViewController: CourseContentListViewController?
    private var courseContentViewController: UIViewController?

    var course: Course!
    var content: CourseContent?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.decideContent()

        self.course.notifyOnChange(self, updateHandler: {}, deleteHandler: { [weak self] in
            self?.closeCourse()
        })

        self.titleView.text = self.course.title

        if let titleView = self.navigationItem.titleView, let text = self.titleView.text {
            let titleWidth = NSString(string: text).size(withAttributes: [NSAttributedStringKey.font: self.titleView.font]).width
            var frame = titleView.frame
            frame.size.width = titleWidth + 2
            titleView.frame = frame
            titleView.setNeedsLayout()
        }

        SpotlightHelper.setUserActivity(for: self.course)
        CrashlyticsHelper.shared.setObjectValue(self.course.id, forKey: "course_id")
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
        self.courseContentListViewController?.refresh(animated: false)
        self.updateContainerView(to: content)
    }

    func updateContainerView(to content: CourseContent) {
        if let viewController = self.courseContentViewController {
            viewController.willMove(toParentViewController: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
            self.courseContentViewController = nil
        }

        guard let courseContentViewController = content.viewController else { return }
        courseContentViewController.configure(for: course)

        self.containerView.addSubview(courseContentViewController.view)
        courseContentViewController.view.frame = self.containerView.bounds
        self.addChildViewController(courseContentViewController)
        courseContentViewController.didMove(toParentViewController: self)
        self.courseContentViewController = courseContentViewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let courseContentListViewController = segue.destination as? CourseContentListViewController {
            courseContentListViewController.delegate = self
            self.courseContentListViewController = courseContentListViewController
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

extension CourseViewController: CourseContentListViewControllerDelegate {

    var accessibleContent: [CourseContent] {
        if self.course.hasEnrollment && self.course.accessible {
            return CourseContent.orderedValues
        } else {
            return CourseContent.orderedValues.filter { $0.acessibleWithoutEnrollment }
        }
    }

    var selectedContent: CourseContent? {
        return self.content
    }

    func change(to content: CourseContent) {
        self.content = content
        self.updateContainerView(to: content)
    }

}
