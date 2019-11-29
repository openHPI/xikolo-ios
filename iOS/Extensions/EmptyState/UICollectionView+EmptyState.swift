//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView: EmptyStateProtocol {

    static func enableEmptyStates() {
        Swizzler.swizzleMethods(for: self,
                                originalSelector: #selector(reloadData),
                                swizzledSelector: #selector(swizzledReload))
        Swizzler.swizzleMethods(for: self,
                                originalSelector: #selector(performBatchUpdates(_:completion:)),
                                swizzledSelector: #selector(swizzledPerformBatchUpdates(_:completion:)))
    }

    @objc private dynamic func swizzledReload() {
        self.swizzledReload()
        self.reloadEmptyState()
    }

    @objc private dynamic func swizzledPerformBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        self.swizzledPerformBatchUpdates(updates, completion: completion)
        self.reloadEmptyState()
    }

    var hasItemsToDisplay: Bool {
        for section in 0..<self.numberOfSections {
            if self.numberOfItems(inSection: section) != 0 {
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
