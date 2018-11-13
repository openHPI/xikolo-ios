//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

final class CoursePresentationController: UIPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {
        let containerView = self.containerView.require()
        let statusBarHeight = UIApplication.shared.isStatusBarHidden || !trueUnlessReduceMotionEnabled ? 0 : max(12, UIApplication.shared.statusBarFrame.height + 4)
        return CGRect(x: 0,
                      y: statusBarHeight,
                      width: containerView.bounds.width,
                      height: containerView.bounds.height - statusBarHeight)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }

    override var shouldRemovePresentersView: Bool {
        return true
    }

}
