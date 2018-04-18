//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseDismissionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private var propertyAnimator: UIViewPropertyAnimator?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.interruptibleAnimator(using: transitionContext).startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // as per documentation, we need to return existing animator for ongoing transition
        if let propertyAnimator = self.propertyAnimator {
            return propertyAnimator
        }

        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let containerView = transitionContext.containerView

        let animationDuration = self.transitionDuration(using: transitionContext)

        let overlayView = containerView.viewWithTag(437)

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
