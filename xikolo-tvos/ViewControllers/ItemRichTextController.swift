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
        textView.isSelectable = true
        textView.panGestureRecognizer.allowedTouchTypes = [ NSNumber(value: UITouchType.indirect.rawValue) ]

        loadingHelper = ViewControllerLoadingHelper(self, rootView: containerView)
        loadingHelper.startLoading(courseItem.title ?? NSLocalizedString("Loading", comment: "Loading"))
    }

    override func richTextLoaded() {
        loadingHelper.stopLoading()

        if courseItem.previous == nil {
            previousButton.isHidden = true
        }
        if courseItem.next == nil {
            nextButton.isHidden = true
        }
    }

}

extension ItemRichTextController {

    @IBAction func showPreviousItem(_ sender: UIButton) {
        showItem(courseItem.previous!)
    }

    @IBAction func showNextItem(_ sender: UIButton) {
        showItem(courseItem.next!)
    }

    func showItem(_ item: CourseItem) {
        navigationController!.popViewController(animated: true)
        delegate?.showItem(item)
    }

}
