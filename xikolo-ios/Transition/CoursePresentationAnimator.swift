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

        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = containerView.bounds
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.0
        blurEffectView.tag = 437
        blurEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.1)

        containerView.addSubview(blurEffectView)

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
            blurEffectView.alpha = 1.0
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
