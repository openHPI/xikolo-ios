//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    var dismissInteractionController: CourseInteractionController?

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        if let nvc = presented as? UINavigationController, let viewController = nvc.topViewController as? CourseViewController {
            self.dismissInteractionController = CourseInteractionController(for: viewController)
        }

        return CoursePresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CoursePresentAnimationController()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CourseDismissAnimationController()
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactionController = self.dismissInteractionController else { return nil }
        return interactionController.interactionInProgress ? interactionController : nil
    }

}
