//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseNavigationController: XikoloNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePullDown(sender:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func closeCourse() {
        self.dismiss(animated: true)
    }

    @objc func handlePullDown(sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.5

        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let progress = max(0.0, min(verticalMovement, 1.0))

        let transitionDelegate = self.transitioningDelegate as? CourseTransitioningDelegate
        guard let interactor = transitionDelegate?.interactionController else { return }

        switch sender.state {
        case .began:
            interactor.hasStarted = true
            self.dismiss(animated: true)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
        default:
            break
        }
    }

}
