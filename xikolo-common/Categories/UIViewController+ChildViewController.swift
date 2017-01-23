//
//  UIViewController+ChildViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 16.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

extension UIViewController {

    func addChildViewController(_ childViewController: UIViewController, into containerView: UIView) {
        containerView.addSubview(childViewController.view)
        childViewController.view.frame = containerView.bounds
        addChildViewController(childViewController)
        childViewController.didMove(toParentViewController: self)
    }

    func removeChildViewControllerFromParent() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }

}
