//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

import CoreData

class CourseItemViewController: UIPageViewController {

    private var previousItem: CourseItem?
    private var nextItem: CourseItem?

    private var previousItemViewController: UIViewController?
    private var nextItemViewController: UIViewController?

    private var swipeDirection: UIPageViewController.NavigationDirection?

    var currentItem: CourseItem? {
        didSet {
            self.trackItemVisit()

            ErrorManager.shared.remember(self.currentItem?.id, forKey: "item_id")

            self.previousItem = self.currentItem?.previousItem
            self.nextItem = self.currentItem?.nextItem
        }
    }

    override func viewDidLoad() {
        self.dataSource = self
        self.delegate = self

        self.view.backgroundColor = .white

        guard let item = self.currentItem else { return }
        guard let newViewController = self.viewController(for: item) else { return }
        newViewController.configure(for: item)
        self.setViewControllers([newViewController], direction: .forward, animated: true)
    }

    private func viewController(for item: CourseItem) -> (UIViewController & CourseItemContentViewController)? {
        guard !item.proctored else {
            return nil // TODO proctored view
        }

        guard item.hasAvailableContent else {
            return nil // TODO: unavailable view
        }

        switch item.contentType {
        case "video"?:
            return R.storyboard.courseLearnings.videoViewController()
        case "rich_text"?:
            return R.storyboard.courseLearnings.richtextViewController()
        default:
            return R.storyboard.courseLearnings.courseItemWebViewController()
        }
    }

    private func trackItemVisit() {
        guard let item = self.currentItem else { return }
        guard !item.proctored else { return }
        guard item.hasAvailableContent else { return }

        CourseItemHelper.markAsVisited(item)
        let context = [
            "content_type": item.contentType,
            "section_id": item.section?.id,
            "course_id": item.section?.course?.id,
        ]
        TrackingHelper.shared.createEvent(.visitedItem, resourceType: .item, resourceId: item.id, context: context)
    }

}

extension CourseItemViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let item = self.previousItem else { return nil }
        guard let newViewController = self.viewController(for: item) else { return nil }
        self.previousItemViewController = newViewController // XXX
        newViewController.configure(for: item)
        return newViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let item = self.nextItem else { return nil }
        guard let newViewController = self.viewController(for: item) else { return nil }
        self.nextItemViewController = newViewController // XXX
        newViewController.configure(for: item)
        return newViewController
    }

}

extension CourseItemViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let pendingViewController = pendingViewControllers.first, pendingViewControllers.count == 1 else {
            preconditionFailure()
        }

        self.viewControllers?.compactMap { $0 as? CourseItemContentViewController }.forEach { $0.prepareForCourseItemChange() }
        if pendingViewController == self.nextItemViewController {
            self.swipeDirection = .forward
        } else if pendingViewController == self.previousItemViewController {
            self.swipeDirection = .reverse
        } else {
            preconditionFailure()
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard let previousViewController = previousViewControllers.first, previousViewControllers.count == 1 else {
            preconditionFailure()
        }

        guard finished && completed else { return }

        if self.swipeDirection == .forward {
            self.currentItem = self.nextItem
            self.previousItemViewController = previousViewController
        } else if self.swipeDirection == .reverse {
            self.currentItem = self.previousItem
            self.nextItemViewController = previousViewController
        } else {
            preconditionFailure()
        }

        self.swipeDirection = nil //XXX there and back?
    }


}
