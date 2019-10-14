//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

extension UITableView: EmptyStateProtocol {

    static func enableEmptyStates() {
        let originalSelector = #selector(reloadData)
        let swizzledSelector = #selector(swizzledReload)

        Swizzler.swizzleMethods(for: self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }

    @objc private dynamic func swizzledReload() {
        swizzledReload()

        if !self.hasItemsToDisplay && self.subviews.count > 1 {
            self.emptyStateView.titleLabel.text = self.emptyStateDataSource?.emptyStateTitleText
            self.emptyStateView.detailLabel.text = self.emptyStateDataSource?.emptyStateDetailText
            self.backgroundView = emptyStateView
        } else {
            self.backgroundView = nil
        }
    }

    var hasItemsToDisplay: Bool {
        guard let numberOfSections = self.dataSource?.numberOfSections?(in: self) else {
            return false
        }

        for section in 0..<numberOfSections {
            if self.dataSource?.tableView(self, numberOfRowsInSection: section) != 0 {
                return true
            }
        }

        return false
    }

}
