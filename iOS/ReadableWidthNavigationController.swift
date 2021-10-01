//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class ReadableWidthNavigationController: UINavigationController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCustomLayoutMargins()
    }

    @available(iOS 11, *)
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        self.updateCustomLayoutMargins()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateCustomLayoutMargins()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _  in
            self.updateCustomLayoutMargins()
        }
    }

    private func updateCustomLayoutMargins() {
        if #available(iOS 11, *) {
            let customInsets = NSDirectionalEdgeInsets.readableContentInsets(for: self)
            self.view.directionalLayoutMargins = customInsets
            self.navigationBar.preservesSuperviewLayoutMargins = true

            if UIDevice.current.userInterfaceIdiom == .pad {
                self.navigationBar.directionalLayoutMargins.leading = customInsets.leading
                self.navigationBar.directionalLayoutMargins.trailing = customInsets.trailing
            }

            self.navigationBar.layoutMarginsDidChange()
        }
    }

}
