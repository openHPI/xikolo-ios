//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    var dismissInteractionController: CourseInteractionController?

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        if let courseNavigationController = presented as? CourseNavigationController {
            self.dismissInteractionController = CourseInteractionController(for: courseNavigationController)
        }

        let presentationController = CoursePresentationController(presentedViewController: presented, presenting: presenting)

        if #available(iOS 13, *) {
            let userInterfaceLevel: UIUserInterfaceLevel = source.view.window?.frameIsFullScreen == true ? .base : .elevated
            presentationController.overrideTraitCollection = UITraitCollection(userInterfaceLevel: userInterfaceLevel)
        }

        return presentationController
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
