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
    var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    var isLoading: Bool {
        return originalViews != nil
    }

    init(_ viewController: UIViewController, rootView: UIView) {
        self.viewController = viewController
        self.rootView = rootView
    }

    convenience init(_ viewController: UIViewController) {
        self.init(viewController, rootView: viewController.view)
    }

    func startLoading(_ activityName: String) {
        originalViews = rootView.subviews.filter { !$0.isHidden && $0.tag != type(of: self).DoNotHideViewTag }

        for view in originalViews {
            view.isHidden = true
        }

        rootView.addSubview(mainView)

        mainView.translatesAutoresizingMaskIntoConstraints = false
        activityNameView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(activityNameView)
        mainView.addSubview(activityIndicatorView)

        activityNameView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        activityNameView.textColor = UIColor.darkGray
        activityNameView.text = activityName

        activityIndicatorView.color = UIColor.darkGray
        activityIndicatorView.startAnimating()

        // Make mainView the same size as the ViewController.
        mainView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: rootView.widthAnchor).isActive = true
        mainView.heightAnchor.constraint(equalTo: rootView.heightAnchor).isActive = true

        // Fix Activity Indicator to the center of mainView.
        activityIndicatorView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true

        // Fix Activity Name to the top of the indicator
        activityNameView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        activityNameView.bottomAnchor.constraint(equalTo: activityIndicatorView.topAnchor, constant: -20).isActive = true
    }

    func stopLoading() {
        assert(originalViews != nil, "Cannot stop loading before it started!")

        for view in originalViews {
            view.alpha = 0
            view.isHidden = false
        }

        UIView.animate(withDuration: 0.5, animations: {
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
