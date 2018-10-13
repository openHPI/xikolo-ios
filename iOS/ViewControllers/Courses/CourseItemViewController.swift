//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseItemViewController: UIViewController {

    private var courseItemViewController: UIViewController?

    var item: CourseItem? {
        didSet {
            self.updateView()
            self.trackItemVisit()
        }
    }

    private func updateView() {
        let animationTime: TimeInterval = 0.15

        self.courseItemViewController?.willMove(toParentViewController: nil)

        // swiftlint:disable multiple_closures_with_trailing_closure
        UIView.animate(withDuration: animationTime, delay: animationTime, options: .curveEaseInOut, animations: {
            self.courseItemViewController?.view.alpha = 0
        }) { _ in
            self.courseItemViewController?.view.removeFromSuperview()
            self.courseItemViewController?.removeFromParentViewController()
            self.courseItemViewController = nil

            guard let item = self.item else { return }
            guard let newViewController = self.viewControllerForCurrentItem else { return }
            newViewController.configure(for: item)
            newViewController.view.frame = self.view.bounds
            newViewController.view.alpha = 0

            self.view.addSubview(newViewController.view)
            self.addChildViewController(newViewController)
            self.courseItemViewController = newViewController

            UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut, animations: {
                newViewController.view.alpha = 1
            }) { _ in
                newViewController.didMove(toParentViewController: self)
            }
        }
    }

    private var viewControllerForCurrentItem: (UIViewController & CourseItemContentViewController)? {
        // TODO if item is protocored

        switch self.item?.contentType {
        case "video"?:
            return R.storyboard.courseLearnings.videoViewController()
        case "rich_text"?:
            return R.storyboard.courseLearnings.richtextViewController()
        default:
            return R.storyboard.courseLearnings.courseItemWebViewController()
        }
    }

    private func trackItemVisit() {
        guard let item = self.item else { return }

        CourseItemHelper.markAsVisited(item)
        let context = [
            "content_type": item.contentType,
            "section_id": item.section?.id,
            "course_id": item.section?.course?.id,
        ]
        TrackingHelper.shared.createEvent(.visitedItem, resourceType: .item, resourceId: item.id, context: context)
    }

}
