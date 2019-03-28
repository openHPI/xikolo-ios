//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CoursePresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            fatalError("to view controller could not be found")
        }

        toViewController.view.transform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.bounds.height)
        transitionContext.containerView.addSubview(toViewController.view)

        let animationDuration = self.transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: animationDuration, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))

        animator.addAnimations {
            toViewController.view.transform = CGAffineTransform.identity
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        animator.startAnimation()
    }
}
