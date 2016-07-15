//
//  ViewControllerLoadingHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 15.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ViewControllerLoadingHelper {

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
        originalViews = rootView.subviews.filter { !$0.hidden }

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

        activityIndicatorView.color = UIColor.darkGrayColor()
        activityIndicatorView.startAnimating()

        // Make mainView the same size as the ViewController.
        rootView.addConstraint(NSLayoutConstraint(item: mainView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: mainView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: mainView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: mainView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))

        // Fix Activity Indicator to the center of mainView.
        mainView.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        mainView.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))

        // Fix Activity Name to the top of the indicator
        mainView.addConstraint(NSLayoutConstraint(item: activityNameView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        mainView.addConstraint(NSLayoutConstraint(item: activityNameView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: activityIndicatorView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -20))
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
