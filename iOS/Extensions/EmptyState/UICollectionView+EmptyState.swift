//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView: EmptyStateProtocol {

    static func enableEmptyStates() {
        let originalSelector = #selector(reloadData)
        let swizzledSelector = #selector(swizzledReload)

        Swizzler.swizzleMethods(for: self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }

    @objc private dynamic func swizzledReload() {
        self.swizzledReload()
        self.reloadEmptyState()
    }

    var hasItemsToDisplay: Bool {
        for section in 0..<self.numberOfSections {
            if self.dataSource?.collectionView(self, numberOfItemsInSection: section) != 0 {
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