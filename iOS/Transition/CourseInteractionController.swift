//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseInteractionController: UIPercentDrivenInteractiveTransition {

    static let dragPercentageThreshold: CGFloat = 0.5
    static let flickVelocityThreshold: CGFloat = 600

    var interactionInProgress = false

    private var shouldCompleteTransition = false
    private weak var navigationController: CourseNavigationController!

    init(for navigationController: CourseNavigationController) {
        super.init()
        self.navigationController = navigationController
        self.prepareGestureRecognizer(for: navigationController)
    }

    private func prepareGestureRecognizer(for navigationController: CourseNavigationController) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        navigationController.addDismissalGestureRecognizer(gesture)
    }

    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let view = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let dragPercentage = max(0.0, min(verticalMovement, 1.0))
        let shouldFinishByDragging = dragPercentage > Self.dragPercentageThreshold

        let velocity = gestureRecognizer.velocity(in: view)
        let shouldFinishByFlicking = velocity.y > Self.flickVelocityThreshold

        switch gestureRecognizer.state {
        case .began:
            self.interactionInProgress = true
            self.navigationController.topViewController?.dismiss(animated: trueUnlessReduceMotionEnabled)
        case .changed:
            self.shouldCompleteTransition = shouldFinishByDragging || shouldFinishByFlicking
            self.update(dragPercentage)
        case .cancelled:
            self.interactionInProgress = false
            self.cancel()
        case .ended:
            self.interactionInProgress = false
            if self.shouldCompleteTransition {
                self.finish()
            } else {
                self.cancel()
            }
        default:
            break
        }
    }
}
