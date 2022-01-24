//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CustomWidthViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.directionalLayoutMargins = NSDirectionalEdgeInsets.customInsets(for: self)
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        self.view.directionalLayoutMargins = NSDirectionalEdgeInsets.customInsets(for: self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.view.directionalLayoutMargins = NSDirectionalEdgeInsets.customInsets(for: self)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _  in
            self.view.directionalLayoutMargins = NSDirectionalEdgeInsets.customInsets(for: self)
        }
    }

}
