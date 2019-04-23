//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseNavigationController: XikoloNavigationController {

    static let dragPercentageThreshold: CGFloat = 0.5
    static let flickVelocityThreshold: CGFloat = 300

    var courseViewController: CourseViewController? {
        return self.viewControllers.first as? CourseViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePullDown(sender:)))
        self.view.addGestureRecognizer(panGestureRecognizer)

        for view in self.view.subviews {
            view.layer.cornerRadius = 16.0
            view.layer.masksToBounds = true

            if #available(iOS 11.0, *) {
                view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var childForStatusBarHidden: UIViewController? {
        let pageViewController = self.topViewController as? UIPageViewController
        return pageViewController?.viewControllers?.first
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        let pageViewController = self.topViewController as? UIPageViewController
        return pageViewController?.viewControllers?.first
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard self.presentedViewController != nil else { return }
        super.dismiss(animated: flag, completion: completion)
    }

    @objc func closeCourse() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        super.dismiss(animated: trueUnlessReduceMotionEnabled)
        feedbackGenerator.impactOccurred()
    }

    @objc func handlePullDown(sender: UIPanGestureRecognizer) {
        let transitionDelegate = self.transitioningDelegate as? CourseTransitioningDelegate
        guard let interactor = transitionDelegate?.interactionController else { return }

        let translation = sender.translation(in: self.view)
        let verticalMovement = translation.y / self.view.bounds.height
        let dragPercentage = max(0.0, min(verticalMovement, 1.0))
        let shouldFinishByDragging = dragPercentage > CourseNavigationController.dragPercentageThreshold

        let velocity = sender.velocity(in: self.view)
        let shouldFinishByFlicking = velocity.y > CourseNavigationController.flickVelocityThreshold

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()

        switch sender.state {
        case .began:
            interactor.hasStarted = true
            super.dismiss(animated: trueUnlessReduceMotionEnabled)
        case .changed:
            interactor.shouldFinish = shouldFinishByDragging || shouldFinishByFlicking
            interactor.update(dragPercentage)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            if interactor.shouldFinish {
                interactor.finish()
                feedbackGenerator.impactOccurred()
            } else {
                interactor.cancel()
            }
        default:
            break
        }
    }

}
