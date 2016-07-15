//
//  TextViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 27.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ItemRichTextController : AbstractItemRichtextViewController {

    @IBOutlet weak var containerView: UIView!

    var loadingHelper: ViewControllerLoadingHelper!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.selectable = true
        textView.panGestureRecognizer.allowedTouchTypes = [ UITouchType.Indirect.rawValue ]

        loadingHelper = ViewControllerLoadingHelper(self, rootView: containerView)
        loadingHelper.startLoading(courseItem.title ?? NSLocalizedString("Loading", comment: "Loading"))
    }

    override func richTextLoaded() {
        loadingHelper.stopLoading()
    }

}
