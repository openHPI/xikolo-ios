//
//  ViewControllerLoadingHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 15.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ViewControllerLoadingHelper {

    static let DoNotHideViewTag = 0xdeadbeef

    weak var viewController: UIViewController!
    weak var rootView: UIView!
    var originalViews: [UIView]!

    var mainView = UIView()
    var activityNameView = UILabel()
    var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

    init(_ viewController: UIViewController, rootView: UIView) {
        self.viewController = viewController
        self.rootView = rootView
    }

    convenience init(_ viewController: UIViewController) {
        self.init(viewController, rootView: viewController.view)
    }

    func startLoading(activityName: String) {
        originalViews = rootView.subviews.filter { !$0.hidden && $0.tag != self.dynamicType.DoNotHideViewTag }

        for view in originalViews {
            view.hidden = true
        }

        rootView.addSubview(mainView)

        mainView.translatesAutoresizingMaskIntoConstraints = false
        activityNameView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(activityNameView)
        mainView.addSubview(activityIndicatorView)

        activityNameView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        activityNameView.textColor = UIColor.darkGrayColor()
        activityNameView.text = activityName

        activityIndicatorView.color = UIColor.darkGrayColor()
        activityIndicatorView.startAnimating()

        // Make mainView the same size as the ViewController.
        mainView.leftAnchor.constraintEqualToAnchor(rootView.leftAnchor).active = true
        mainView.topAnchor.constraintEqualToAnchor(rootView.topAnchor).active = true
        mainView.widthAnchor.constraintEqualToAnchor(rootView.widthAnchor).active = true
        mainView.heightAnchor.constraintEqualToAnchor(rootView.heightAnchor).active = true

        // Fix Activity Indicator to the center of mainView.
        activityIndicatorView.centerXAnchor.constraintEqualToAnchor(mainView.centerXAnchor).active = true
        activityIndicatorView.centerYAnchor.constraintEqualToAnchor(mainView.centerYAnchor).active = true

        // Fix Activity Name to the top of the indicator
        activityNameView.centerXAnchor.constraintEqualToAnchor(mainView.centerXAnchor).active = true
        activityNameView.bottomAnchor.constraintEqualToAnchor(activityIndicatorView.topAnchor, constant: -20).active = true
    }

    func stopLoading() {
        assert(originalViews != nil, "Cannot stop loading before it started!")

        for view in originalViews {
            view.alpha = 0
            view.hidden = false
        }

        UIView.animateWithDuration(0.5, animations: {
            for view in self.originalViews {
                view.alpha = 1
            }
            self.mainView.alpha = 0
        }, completion: { completed in
            self.mainView.removeFromSuperview()
            self.originalViews = nil
        })
    }

}
