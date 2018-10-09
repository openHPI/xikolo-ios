//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseDismissionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private var propertyAnimator: UIViewPropertyAnimator?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.interruptibleAnimator(using: transitionContext).startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // as per documentation, we need to return existing animator for ongoing transition
        if let propertyAnimator = self.propertyAnimator {
            return propertyAnimator
        }

        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            fatalError("from view controller could not be found")
        }

        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            fatalError("from view controller could not be found")
        }

        // Update frame of toViewController's view to avoid UI glitches when dismissing a course
        // in a different device orientation compared to the orientation the course was opened in
        if let windowFrame = AppDelegate.instance().window?.frame {
            toViewController.view.frame = windowFrame
        }

        let containerView = transitionContext.containerView
        containerView.insertSubview(toViewController.view, at: 0)

        let overlayView = containerView.viewWithTag(437)
        overlayView?.subviews.forEach { $0.removeFromSuperview() }

        if let snapshot = toViewController.view.snapshotView(afterScreenUpdates: true) {
            snapshot.alpha = 0.2
            overlayView?.addSubview(snapshot)
        }

        let animationDuration = self.transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: animationDuration, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))

        animator.addAnimations {
            fromViewController.view.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
            overlayView?.alpha = 0
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.propertyAnimator = nil // reset animator because the current transition ended
        }

        self.propertyAnimator = animator
        return animator
    }
}
