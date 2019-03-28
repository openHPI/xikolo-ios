//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

final class CoursePresentationController: UIPresentationController {

    private var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.alpha = 0.0
        return dimmingView
    }()

    private var topOffset: CGFloat {
        let topMargin: CGFloat = {
            if #available(iOS 11, *) {
                return self.containerView?.safeAreaInsets.top ?? 0
            } else {
                return self.containerView?.layoutMargins.top ?? 0
            }
        }()

        return topMargin > 0 ? topMargin + 4 : 0
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        let containerView = self.containerView.require()
        let size = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerView.bounds.size)
        let origin = CGPoint(x: 0, y: self.topOffset)
        return CGRect(origin: origin, size: size)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else {
            return
        }

        containerView.addSubview(self.dimmingView)

        NSLayoutConstraint.activate([
            self.dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            self.dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            self.dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            self.dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        ])

        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.dimmingView.alpha = 1.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.dimmingView.alpha = 0.1
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.1
        })
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }

    override var shouldRemovePresentersView: Bool {
        return true
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height - self.topOffset)
    }

}
