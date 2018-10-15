//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

import CoreData

class CourseItemViewController: UIPageViewController {

//    private var courseItemViewController: UIViewController?

    private var previousItem: CourseItem?
    private var nextItem: CourseItem?

    private var previousItemViewController: UIViewController?
    private var nextItemViewController: UIViewController?

    private var swipeDirection: UIPageViewController.NavigationDirection?

    var currentItem: CourseItem? {
        didSet {
//            self.updateView()
            self.trackItemVisit()

        }
    }

    override func viewDidLoad() {
        self.dataSource = self
        self.delegate = self

        self.previousItem = self.currentItem?.previousItem
        self.nextItem = self.currentItem?.nextItem

        guard let item = self.currentItem else { return }
        guard let newViewController = self.viewController(for: item) else { return }
        newViewController.configure(for: item)
        self.setViewControllers([newViewController], direction: .forward, animated: true)
    }

//    private func updateView() {
//        guard let item = self.item else { return }
//        guard let newViewController = self.viewControllerForCurrentItem else { return }
//        newViewController.configure(for: item)
//        self.setViewControllers([newViewController], direction: .forward, animated: true)
//
//        let animationTime: TimeInterval = 0.15
//
//        self.courseItemViewController?.willMove(toParentViewController: nil)
//
//        // swiftlint:disable multiple_closures_with_trailing_closure
//        UIView.animate(withDuration: animationTime, delay: animationTime, options: .curveEaseInOut, animations: {
//            self.courseItemViewController?.view.alpha = 0
//        }) { _ in
//            self.courseItemViewController?.view.removeFromSuperview()
//            self.courseItemViewController?.removeFromParentViewController()
//            self.courseItemViewController = nil
//
//            guard let item = self.item else { return }
//            guard let newViewController = self.viewControllerForCurrentItem else { return }
//            newViewController.configure(for: item)
//            newViewController.view.frame = self.view.bounds
//            newViewController.view.alpha = 0
//
//            self.view.addSubview(newViewController.view)
//            self.addChildViewController(newViewController)
//            self.courseItemViewController = newViewController
//
//            UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut, animations: {
//                newViewController.view.alpha = 1
//            }) { _ in
//                newViewController.didMove(toParentViewController: self)
//            }
//        }
//    }

    private func viewController(for item: CourseItem) -> (UIViewController & CourseItemContentViewController)? {
        // TODO if item is protocored

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
            self.previousItem = self.currentItem
            self.currentItem = self.nextItem
            self.nextItem = self.currentItem?.nextItem
            self.previousItemViewController = previousViewController
        } else if self.swipeDirection == .reverse {
            self.nextItem = self.currentItem
            self.currentItem = self.previousItem
            self.previousItem = self.currentItem?.previousItem
            self.nextItemViewController = previousViewController
        } else {
            preconditionFailure()
        }

        self.swipeDirection = nil //XXX there and back?
    }


}
