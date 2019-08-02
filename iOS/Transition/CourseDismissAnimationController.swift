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

        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            fatalError("from view controller could not be found")
        }

        guard let toVC = transitionContext.viewController(forKey: .to) else {
            fatalError("from view controller could not be found")
        }

        transitionContext.containerView.insertSubview(toVC.view, at: 0)

        // Update frame of toViewController's view to avoid UI glitches when dismissing a course
        // in a different device orientation compared to the orientation the course was opened in
        toVC.view.frame = transitionContext.finalFrame(for: toVC)

        let duration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: UICubicTimingParameters(animationCurve: .easeIn))

        animator.addAnimations {
            fromVC.view.transform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.bounds.height)
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.propertyAnimator = nil // reset animator because the current transition ended
        }

        self.propertyAnimator = animator
        return animator
    }
}
