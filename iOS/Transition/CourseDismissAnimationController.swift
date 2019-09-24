//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private var propertyAnimator: UIViewPropertyAnimator?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.interruptibleAnimator(using: transitionContext).startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let propertyAnimator = self.propertyAnimator {
            return propertyAnimator
        }

        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            fatalError("from view controller could not be found")
        }

        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            fatalError("from view controller could not be found")
        }

        transitionContext.containerView.insertSubview(toViewController.view, at: 0)

        // Update frame of toViewController's view to avoid UI glitches when dismissing a course
        // in a different device orientation compared to the orientation the course was opened in
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)

        let duration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: UICubicTimingParameters(animationCurve: .easeIn))

        animator.addAnimations {
            fromViewController.view.transform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.bounds.height)
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.propertyAnimator = nil // reset animator because the current transition ended
        }

        self.propertyAnimator = animator
        return animator
    }
}
