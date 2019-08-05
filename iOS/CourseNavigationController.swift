//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseNavigationController: XikoloNavigationController {

    private var pendingGestureRecognizer: UIGestureRecognizer?

    var courseViewController: CourseViewController? {
        return self.viewControllers.first as? CourseViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let gestureRecognizer = self.pendingGestureRecognizer {
            self.view.addGestureRecognizer(gestureRecognizer)
        }
    }

    override var childForStatusBarHidden: UIViewController? {
        let pageViewController = self.topViewController as? UIPageViewController
        return pageViewController?.viewControllers?.first
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        let pageViewController = self.topViewController as? UIPageViewController
        return pageViewController?.viewControllers?.first
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let pageViewController = self.topViewController as? UIPageViewController else {
            return
        }

        guard pageViewController.viewControllers?.first is VideoViewController else {
            return
        }

        for view in self.view.subviews {
            view.layer.masksToBounds = !self.navigationBar.isHidden
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard self.presentedViewController != nil else { return }
        super.dismiss(animated: flag, completion: completion)
    }

    func addDismissalGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if let view = self.viewIfLoaded {
            view.addGestureRecognizer(gestureRecognizer)
        } else {
            self.pendingGestureRecognizer = gestureRecognizer
        }
    }

    @objc func closeCourse() {
        super.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

}
