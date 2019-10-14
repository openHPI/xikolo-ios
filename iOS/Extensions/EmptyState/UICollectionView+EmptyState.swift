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

    /// The object that acts as the delegate of the empty state view.
    public weak var emptyStateDelegate: EmptyStateDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emptyStateDelegate) as? EmptyStateDelegate
        }

        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.emptyStateDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    /// The object that acts as the data source of the empty state view.
    public weak var emptyStateDataSource: EmptyStateDataSource? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emptyStateDataSource) as? EmptyStateDataSource
        }

        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.emptyStateDataSource, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    /// The original value before enable/disable scrolling.
    var originalScrollingValue: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.originalScrollingValue) as? Bool) ?? isScrollEnabled
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKeys.originalScrollingValue, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }

    @objc private dynamic func swizzledReload() {
        swizzledReload()

        guard emptyStateDataSource != nil else { return }

        if numberOfItems == 0 && self.subviews.count > 1 {
            originalScrollingValue = isScrollEnabled
            isScrollEnabled = emptyStateDelegate?.enableScrollForEmptyState() ?? true

            backgroundView = emptyStateView
            if let emptyStateView = emptyStateView as? EmptyStateView {
                let datasource = self.emptyStateDataSource
                emptyStateView.titleLabel.text = datasource?.titleText
                emptyStateView.detailLabel.text = datasource?.detailText
//                emptyStateView.image = datasource?.imageForEmptyDataSet()
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
            removeEmptyView()
            isScrollEnabled = originalScrollingValue
        }
    }
}
