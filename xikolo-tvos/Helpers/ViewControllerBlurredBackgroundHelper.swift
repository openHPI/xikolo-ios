//
//  ViewControllerBlurredBackgroundHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 21.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ViewControllerBlurredBackgroundHelper {

    weak var rootView: UIView!
    var imageView: UIImageView

    required init(rootView: UIView) {
        self.rootView = rootView

        imageView = UIImageView()
        imageView.frame = rootView.frame

        let blurEffect = UIBlurEffect(style: .ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imageView.frame
        imageView.addSubview(blurEffectView)

        rootView.insertSubview(imageView, atIndex: 0)
    }

}
