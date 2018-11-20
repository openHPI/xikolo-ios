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
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            fatalError("from view controller could not be found")
        }

        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            fatalError("to view controller could not be found")
        }

        let containerView = transitionContext.containerView

        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black
        overlayView.frame = containerView.bounds
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.alpha = 0.0
        overlayView.tag = 437

        if let snapshot = fromViewController.view.snapshotView(afterScreenUpdates: true) {
            snapshot.alpha = 0.2
            snapshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlayView.addSubview(snapshot)
        }

        containerView.addSubview(overlayView)

        toViewController.view.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        containerView.addSubview(toViewController.view)

        let animationDuration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            toViewController.view.transform = CGAffineTransform.identity
            overlayView.alpha = 1.0
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
