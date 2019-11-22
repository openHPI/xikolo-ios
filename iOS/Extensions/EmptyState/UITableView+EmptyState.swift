//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

extension UITableView: EmptyStateProtocol {

    static func enableEmptyStates() {
        Swizzler.swizzleMethods(for: self, originalSelector: #selector(reloadData), swizzledSelector: #selector(swizzledReload))
        Swizzler.swizzleMethods(for: self, originalSelector: #selector(endUpdates), swizzledSelector: #selector(swizzledEndUpdates))
    }

    @objc private dynamic func swizzledReload() {
        self.swizzledReload()
        self.reloadEmptyState()
    }

    @objc private dynamic func swizzledEndUpdates() {
        self.swizzledEndUpdates()
        self.reloadEmptyState()
    }

    var hasItemsToDisplay: Bool {
        for section in 0..<self.numberOfSections {
            if self.numberOfRows(inSection: section) != 0 {
                return true
            }
        }

        return false
    }

    func reloadEmptyState() {
        if self.hasItemsToDisplay {
            self.backgroundView = nil
        } else {
            self.emptyStateView.titleLabel.text = self.emptyStateDataSource?.emptyStateTitleText
            self.emptyStateView.detailLabel.text = self.emptyStateDataSource?.emptyStateDetailText
            self.backgroundView = self.emptyStateView
        }
    }

}
