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
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    var delegate: ItemViewControllerDelegate?

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

        if courseItem.previous == nil {
            previousButton.hidden = true
        }
        if courseItem.next == nil {
            nextButton.hidden = true
        }
    }

}

extension ItemRichTextController {

    @IBAction func showPreviousItem(sender: UIButton) {
        showItem(courseItem.previous!)
    }

    @IBAction func showNextItem(sender: UIButton) {
        showItem(courseItem.next!)
    }

    func showItem(item: CourseItem) {
        navigationController!.popViewControllerAnimated(true)
        delegate?.showItem(item)
    }

}
