//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseInteractionController: UIPercentDrivenInteractiveTransition {

    static let dragPercentageThreshold: CGFloat = 0.5
    static let flickVelocityThreshold: CGFloat = 300

    var interactionInProgress = false

    private var shouldCompleteTransition = false
    private weak var viewController: CourseViewController!

    init(for viewController: CourseViewController) {
        super.init()
        self.viewController = viewController
        self.prepareGestureRecognizer(for: viewController)
    }

    private func prepareGestureRecognizer(for viewController: CourseViewController) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        viewController.addDismissalGestureRecognizer(gesture)
    }

    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let view = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let dragPercentage = max(0.0, min(verticalMovement, 1.0))
        let shouldFinishByDragging = dragPercentage > CourseInteractionController.dragPercentageThreshold

        let velocity = gestureRecognizer.velocity(in: view)
        let shouldFinishByFlicking = velocity.y > CourseInteractionController.flickVelocityThreshold

        switch gestureRecognizer.state {
        case .began:
            self.interactionInProgress = true
            self.viewController.dismiss(animated: true)
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
