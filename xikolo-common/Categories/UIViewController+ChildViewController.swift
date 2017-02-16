//
//  UIViewController+ChildViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 16.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

extension UIViewController {

    func addChildViewController(childViewController: UIViewController, into containerView: UIView) {
        containerView.addSubview(childViewController.view)
        childViewController.view.frame = containerView.bounds
        addChildViewController(childViewController)
        childViewController.didMoveToParentViewController(self)
    }

    func removeChildViewControllerFromParent() {
        willMoveToParentViewController(nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }

}
