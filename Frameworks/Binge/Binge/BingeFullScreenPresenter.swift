//
//  BingeFullScreenPresenter.swift
//  Binge
//
//  Created by Max Bothe on 05.02.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import UIKit

class BingeFullScreenPresenter {

    let viewController: UIViewController
    let originalWindow: UIWindow
    let originalParent: UIViewController
    let originalContainer: UIView

    var newWindow: UIWindow?

    init?(for viewController: UIViewController) {
        self.viewController = viewController

        guard let window = UIApplication.shared.keyWindow else {
            return nil
        }

        guard let parent = viewController.parent else {
            return nil
        }

        guard let container = viewController.view.superview else {
            return nil
        }

        self.originalWindow = window
        self.originalParent = parent
        self.originalContainer = container
    }

    func open() {
        self.viewController.presentedViewController?.dismiss(animated: false)

        self.viewController.willMove(toParent: nil)
        self.viewController.removeFromParent()
        self.viewController.view.removeFromSuperview()

        self.originalWindow.addSubview(self.viewController.view)
        self.viewController.view.frame = self.originalContainer.convert(self.viewController.view.frame, to: self.originalWindow)

        self.viewController.view.layer.cornerRadius = self.originalContainer.layer.cornerRadius
        self.viewController.view.layer.masksToBounds = self.viewController.view.layer.cornerRadius > 0

        UIView.transition(with: self.originalWindow, duration: 0.25, options: .curveEaseInOut, animations: {
            self.viewController.view.frame = self.originalWindow.frame
            self.viewController.view.layer.cornerRadius = 0
            self.viewController.view.layoutIfNeeded()
        }) { _ in
            self.viewController.view.removeFromSuperview()
            self.newWindow = UIWindow()
            self.newWindow?.rootViewController = self.viewController
            self.newWindow?.makeKeyAndVisible()
            self.newWindow?.frame = UIScreen.main.bounds
        }
    }

    func close() {
        self.viewController.presentedViewController?.dismiss(animated: false)

        self.originalWindow.addSubview(self.viewController.view)
        self.originalWindow.makeKeyAndVisible()

        self.viewController.view.layer.cornerRadius = self.originalContainer.layer.cornerRadius
        self.viewController.view.layer.masksToBounds = self.viewController.view.layer.cornerRadius > 0

        UIView.transition(with: self.originalWindow, duration: 0.25, options: .curveEaseInOut, animations: {
            self.viewController.view.frame = self.originalWindow.convert(self.originalContainer.frame, from: self.originalParent.view)
            self.viewController.view.layoutIfNeeded()
        }) { _ in
            self.viewController.view.removeFromSuperview()
            self.originalParent.addChild(self.viewController)
            self.originalContainer.addSubview(self.viewController.view)
            self.viewController.didMove(toParent: self.originalParent)
            self.viewController.view.frame = self.originalContainer.bounds
        }
    }

}
