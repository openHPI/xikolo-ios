//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CoursePresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView

        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        overlayView.frame = containerView.bounds
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.alpha = 0.0
        overlayView.tag = 437

        containerView.addSubview(overlayView)

        let animationDuration = transitionDuration(using: transitionContext)

        toViewController.view.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        toViewController.view.layer.shadowColor = UIColor.black.cgColor
        toViewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 16.0)
        toViewController.view.layer.shadowOpacity = 0.3
        toViewController.view.layer.shadowRadius = 24.0

        for subview in toViewController.view.subviews {
            subview.layer.cornerRadius = 16.0
            subview.clipsToBounds = true

            if #available(iOS 11.0, *) {
                subview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        }

        containerView.addSubview(toViewController.view)

        UIView.animate(withDuration: animationDuration, animations: {
            toViewController.view.transform = CGAffineTransform.identity
            overlayView.alpha = 1.0
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
