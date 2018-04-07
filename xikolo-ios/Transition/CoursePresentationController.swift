//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

final class CoursePresentationController: UIPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {
        let layoutFrame = containerView!.readableContentGuide.layoutFrame
        let margins = containerView!.layoutMargins.left + containerView!.layoutMargins.right
        let statusBarHeight = max(12, UIApplication.shared.statusBarFrame.height + 4)

        var x = layoutFrame.origin.x - containerView!.layoutMargins.left
        var width = layoutFrame.size.width + margins
        var height = containerView!.bounds.height - statusBarHeight

        if #available(iOS 11.0, *) {
            x = max(x, containerView!.safeAreaLayoutGuide.layoutFrame.origin.x)
            width = min(width, containerView!.safeAreaLayoutGuide.layoutFrame.width)
        } else if self.traitCollection.verticalSizeClass == .regular {
            height -= statusBarHeight
        }

        return CGRect(x: x, y: statusBarHeight, width: width, height: height)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }

}
