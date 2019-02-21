//
//  BingeFullScreenPresenter.swift
//  Binge
//
//  Created by Max Bothe on 05.02.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import UIKit

struct BingeFullScreenPresenter {

    let viewController: UIViewController
    let originalParent: UIViewController
    let window: UIWindow
    let originalRootViewController: UIViewController
    let originalContainer: UIView

    init?(for viewController: UIViewController) {
        self.viewController = viewController

        guard let parent = viewController.parent else {
            return nil
        }

        guard let window = UIApplication.shared.keyWindow else {
            return nil
        }

        guard let rootViewController = window.rootViewController else {
            return nil
        }

        guard let container = viewController.view.superview else {
            return nil
        }

        self.originalParent = parent
        self.window = window
        self.originalRootViewController = rootViewController
        self.originalContainer = container
    }

    func open() {
        self.viewController.willMove(toParent: nil)
        self.viewController.removeFromParent()
        self.viewController.view.removeFromSuperview()

        self.window.addSubview(self.viewController.view)
        self.viewController.view.frame = self.originalContainer.frame

        self.viewController.view.layer.cornerRadius = self.originalContainer.layer.cornerRadius
        self.viewController.view.layer.masksToBounds = self.viewController.view.layer.cornerRadius > 0

        UIView.transition(with: self.window, duration: 0.25, options: .curveEaseInOut, animations: {
            self.viewController.view.frame = self.window.frame
            self.viewController.view.layer.cornerRadius = 0
            self.viewController.view.layoutIfNeeded()
        }) { _ in
            self.viewController.view.removeFromSuperview()
            self.window.rootViewController = self.viewController
        }
    }

    func close() {
        self.originalRootViewController.view.setNeedsLayout()
        self.originalRootViewController.view.layoutIfNeeded()

        self.window.rootViewController = self.originalRootViewController
        self.window.addSubview(self.viewController.view)

        self.viewController.view.layer.cornerRadius = self.originalContainer.layer.cornerRadius
        self.viewController.view.layer.masksToBounds = self.viewController.view.layer.cornerRadius > 0

        CATransaction.flush()

        UIView.transition(with: self.window, duration: 0.25, options: .curveEaseInOut, animations: {
            self.viewController.view.frame = self.originalContainer.frame
            self.viewController.view.layoutIfNeeded()
        }) { _ in
            self.viewController.view.removeFromSuperview()
            self.originalParent.addChild(self.viewController)
            self.originalContainer.addSubview(self.viewController.view)
            self.viewController.didMove(toParent: self.originalParent)
            self.viewController.view.frame = self.originalContainer.convert(self.viewController.view.frame, from: self.window)
        }
    }

}
