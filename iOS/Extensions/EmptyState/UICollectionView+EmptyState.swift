//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView: EmptyStateProtocol {

    static func configure() {
        let originalSelector = #selector(reloadData)
        let swizzledSelector = #selector(swizzledReload)

        Swizzler.swizzleMethods(for: self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }

    @objc private dynamic func swizzledReload() {
        swizzledReload()

        if !self.hasItemsToDisplay && self.subviews.count > 1 {
            self.backgroundView = emptyStateView
            if let emptyStateView = emptyStateView as? EmptyStateView {
                emptyStateView.titleLabel.text = self.emptyStateDataSource?.emptyStateTitleText
                emptyStateView.detailLabel.text = self.emptyStateDataSource?.emptyStateDetailText
            } else {
                emptyStateView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    emptyStateView.heightAnchor.constraint(equalTo: heightAnchor),
                    emptyStateView.widthAnchor.constraint(equalTo: widthAnchor),
                    emptyStateView.centerYAnchor.constraint(equalTo: centerYAnchor),
                    emptyStateView.centerXAnchor.constraint(equalTo: centerXAnchor)
                ])
            }
        } else {
            self.backgroundView = nil
        }
    }

    var hasItemsToDisplay: Bool {
        guard let numberOfSections = self.dataSource?.numberOfSections?(in: self) else {
            return false
        }

        for section in 0..<numberOfSections {
            if self.dataSource?.collectionView(self, numberOfItemsInSection: section) != 0 {
                return true
            }
        }

        return false
    }

}
