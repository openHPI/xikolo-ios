//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleView: UILabel!

    var containerContentViewController: UIViewController?
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

    func decideContent() {
        guard course.hasEnrollment else {
            self.updateContainerView(to: .courseDetails)
            return
        }

        if let content = self.content { // it already got set from outside
            self.updateContainerView(to: content)
        } else {
            self.updateContainerView(to: course.accessible ? .learnings : .courseDetails)
        }
    }

    func updateContainerView(to content: CourseContent) {
        if let viewController = self.containerContentViewController {
            viewController.willMove(toParentViewController: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
            self.containerContentViewController = nil
        }

        self.content = content

        let configuredViewController = content.viewControllerConfigured(for: course)
        self.containerView.addSubview(configuredViewController.view)
        configuredViewController.view.frame = self.containerView.bounds
        self.addChildViewController(configuredViewController)
        configuredViewController.didMove(toParentViewController: self)
        self.containerContentViewController = configuredViewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let courseContentListViewController = segue.destination as? CourseContentListViewController {
            courseContentListViewController.delegate = self
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

extension CourseViewController: CourseContentListViewControllerDelegate {

    func change(to content: CourseContent) {
        self.updateContainerView(to: content)
    }

}
