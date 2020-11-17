//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CustomWidthTableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11, *) {
            self.view.directionalLayoutMargins = NSDirectionalEdgeInsets.customInsets(for: self)
        }
    }

    @available(iOS 11, *)
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        self.view.directionalLayoutMargins = NSDirectionalEdgeInsets.customInsets(for: self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 11, *) {
            self.view.directionalLayoutMargins = NSDirectionalEdgeInsets.customInsets(for: self)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _  in
            if #available(iOS 11, *) {
                self.view.directionalLayoutMargins = NSDirectionalEdgeInsets.customInsets(for: self)
            }
        }
    }

}
