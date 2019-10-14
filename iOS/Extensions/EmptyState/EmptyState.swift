//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

public protocol EmptyStateDelegate: class {

}

public extension EmptyStateDelegate {

}


/// This protocol provides the table view object with the information it needs to construct and modify a `EmptyStateView`.
public protocol EmptyStateDataSource: class {

    var titleText: String? { get }
    var detailText: String? { get }

}

// MARK: - EmptyStateDataSource Default
public extension EmptyStateDataSource {

    var titleText: String? { nil }
    var detailText: String? { nil }

}

struct AssociatedKeys {
    static var emptyStateDelegate = "emptyStateDelegate"
    static var emptyStateDataSource = "emptyStateDataSource"
    static var emptyStateView = "emptyStateView"
}

/// This protocol provides the basic needed to override emptyViewState on anyclass that supports it
protocol EmptyStateProtocol: AnyObject {
    static func configure()

    var numberOfItems: Int { get }
    var emptyStateDelegate: EmptyStateDelegate? { get set }
    var emptyStateDataSource: EmptyStateDataSource? { get set }
    var emptyStateView: UIView { get set }
}

extension EmptyStateProtocol {

    var emptyStateView: UIView {
        get {
            guard let emptyStateView = objc_getAssociatedObject(self, &AssociatedKeys.emptyStateView) as? UIView else {
                let emptyStateView = EmptyStateView()
                self.emptyStateView = emptyStateView
                return emptyStateView
            }
            return emptyStateView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyStateView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var numberOfItems: Int {
        var items = 0
        let numberOfSections = getNumberOfSections()
        for section in 0..<numberOfSections {
            items += getNumberOfItems(in: section)
        }
        return items
    }

    private func getNumberOfSections() -> Int {
        return (self as? UITableView).flatMap { $0.dataSource?.numberOfSections?(in: $0) } ??
            (self as? UICollectionView).flatMap { $0.dataSource?.numberOfSections?(in: $0) } ?? 1
    }

    private func getNumberOfItems(in section: Int) -> Int {
        return (self as? UITableView).flatMap { $0.dataSource?.tableView($0, numberOfRowsInSection: section) } ??
            (self as? UICollectionView).flatMap { $0.dataSource?.collectionView($0, numberOfItemsInSection: section) } ?? 1
    }
}
