//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

final class CoursePresentationController: UIPresentationController {

    private var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.alpha = 0.0
        return dimmingView
    }()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13, *) {
            let userInterfaceLevel: UIUserInterfaceLevel = self.containerView?.window?.isFrameFullScreen == true ? .base : .elevated
            self.overrideTraitCollection = UITraitCollection(userInterfaceLevel: userInterfaceLevel)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if #available(iOS 13, *) {
            let userInterfaceLevel: UIUserInterfaceLevel = self.containerView?.window?.isFullScreen(withSize: size) ?? true ? .base : .elevated
            self.overrideTraitCollection = UITraitCollection(userInterfaceLevel: userInterfaceLevel)
        }
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

        // swiftlint:disable:next trailing_closure
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.dimmingView.alpha = 0.1
            return
        }

        // swiftlint:disable:next trailing_closure
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.1
        })
    }

    override var shouldRemovePresentersView: Bool {
        return true
    }

}
