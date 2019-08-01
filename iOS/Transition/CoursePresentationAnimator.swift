//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CoursePresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }

        toVC.view.transform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.bounds.height)
        transitionContext.containerView.addSubview(toVC.view)

        let duration = self.transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: UICubicTimingParameters(animationCurve: .easeOut))

        animator.addAnimations {
            toVC.view.transform = CGAffineTransform.identity
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        animator.startAnimation()
    }

}
