//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

public protocol EmptyStateDelegate: class {
    func enableScrollForEmptyState() -> Bool
}

public extension EmptyStateDelegate {

    func enableScrollForEmptyState() -> Bool {
        return true
    }

}


/// This protocol provides the table view object with the information it needs to construct and modify a `EmptyStateView`.
public protocol EmptyStateDataSource: class {

    /// Asks the data source for the description of the `EmptyStateView`.
    ///
    /// - Returns: An instance of UIImage as icon of the `EmptyStateView`.
    func imageForEmptyDataSet() -> UIImage?

    var titleText: String? { get }
    var detailText: String? { get }

    /// Ask the data source for a custom view to be used as Empty State View.
    ///
    /// - Returns: The custom view to be used.
    func customViewForEmptyState() -> UIView?

}

// MARK: - EmptyStateDataSource Default
public extension EmptyStateDataSource {

    func imageForEmptyDataSet() -> UIImage? {
        return nil
    }

    var titleText: String? { nil }
    var detailText: String? { nil }

    func customViewForEmptyState() -> UIView? {
        return nil
    }

}

struct AssociatedKeys {
    static var emptyStateDelegate = "emptyStateDelegate"
    static var emptyStateDataSource = "emptyStateDataSource"
    static var emptyStateView = "emptyStateView"
    static var originalScrollingValue = "originalScrollingValue"
}

/// This protocol provides the basic needed to override emptyViewState on anyclass that supports it
protocol EmptyStateProtocol: AnyObject {
    static func configure()
    func removeEmptyView()

    var numberOfItems: Int { get }
    var emptyStateDelegate: EmptyStateDelegate? { get set }
    var emptyStateDataSource: EmptyStateDataSource? { get set }
    var emptyStateView: UIView { get set }
}

extension EmptyStateProtocol {

    func removeEmptyView() {
        if emptyStateView.superview != nil {
            emptyStateView.removeFromSuperview()
        }
    }

    var emptyStateView: UIView {
        get {
            guard let emptyStateView = objc_getAssociatedObject(self, &AssociatedKeys.emptyStateView) as? UIView else {
                let emptyStateView = emptyStateDataSource?.customViewForEmptyState() ?? EmptyStateView()
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

//protocol EmptyStateDataSource: AnyObject {
//
//    var titleText: String? { get }
//    var detailText: String? { get }
//
//}
//
//extension EmptyStateDataSource {
//
//    var titleText: String? { nil }
//    var detailText: String? { nil }
//
//}
//
//protocol EmptyStateDelegate: AnyObject {
//
//    var shouldFadeIn: Bool { get }
//    var shouldDisplay: Bool { get }
//    var isTouchAllowed: Bool { get }
//    var isScrollAllowed: Bool { get }
//
//}
//
//extension EmptyStateDelegate {
//
//    var shouldFadeIn: Bool { true }
//    var shouldDisplay: Bool { true }
//    var isTouchAllowed: Bool { true }
//    var isScrollAllowed: Bool { false }
//
//}
//
//
//protocol EmptyStateProtocol: AnyObject {
////    static func configure()
////    func removeEmptyView()
//
//    var numberOfItems: Int { get }
//    var emptyStateDelegate: EmptyStateDelegate? { get set }
//    var emptyStateDataSource: EmptyStateDataSource? { get set }
//    var emptyStateView: UIView { get set }
//
//}
//
//extension EmptyStateProtocol where Self: UIView {
//
//    weak var emptyStateDelegate: EmptyStateDelegate? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.emptyStateDelegate) as? EmptyStateDelegate
//        }
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(self, &AssociatedKeys.emptyStateDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//
//    weak var emptyStateDataSource: EmptyStateDataSource? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.emptyStateDataSource) as? EmptyStateDataSource
//        }
//
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(self, &AssociatedKeys.emptyStateDataSource, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
////                self.configure()
//            }
//        }
//    }
//
//    var emptyStateView: EmptyStateView {
//        get {
//            guard let emptyStateView = objc_getAssociatedObject(self, &AssociatedKeys.emptyStateView) as? EmptyStateView else {
//                let emptyStateView = EmptyStateView()
//                self.emptyStateView = emptyStateView
//                return emptyStateView
//            }
//            return emptyStateView
//        }
//
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.emptyStateView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//
//    func removeEmptyView() {
//        if self.emptyStateView.superview != nil {
//            self.emptyStateView.removeFromSuperview()
//        }
//    }
//
//    func reload() {
//        guard self.emptyStateDataSource != nil else { return }
//        if self.numberOfItems == 0 && !self.subviews.isEmpty {
////            let isScrollAllowed = self.emptyStateDelegate?.isScrollAllowed ?? true
//
//            self.emptyStateView.titleLabel = self.emptyStateDataSource?.titleText
//            self.emptyStateView.detailLabel = self.emptyStateDataSource?.detailText
//        }
//    }
//
//}
//
//
