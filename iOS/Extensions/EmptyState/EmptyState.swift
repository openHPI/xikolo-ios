//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

public protocol EmptyStateDelegate: AnyObject {
    func didTapOnEmptyStateView()
}

/// This protocol provides the table view object with the information it needs to construct and modify a `EmptyStateView`.
public protocol EmptyStateDataSource: AnyObject {

    var emptyStateTitleText: String { get }
    var emptyStateDetailText: String? { get }

}

// MARK: - EmptyStateDataSource Default
public extension EmptyStateDataSource {

    var emptyStateDetailText: String? { nil }

}

enum AssociatedKeys {
    static var emptyStateDelegate = "emptyStateDelegate"
    static var emptyStateDataSource = "emptyStateDataSource"
    static var emptyStateView = "emptyStateView"
}

/// This protocol provides the basic needed to override emptyViewState on anyclass that supports it
protocol EmptyStateProtocol: AnyObject {
    var emptyStateDelegate: EmptyStateDelegate? { get set }
    var emptyStateDataSource: EmptyStateDataSource? { get set }
    var emptyStateView: EmptyStateView { get set }
    var hasItemsToDisplay: Bool { get }

    func reloadEmptyState()
}

extension EmptyStateProtocol {

    var emptyStateView: EmptyStateView {
        get {
            guard let emptyStateView = objc_getAssociatedObject(self, &AssociatedKeys.emptyStateView) as? EmptyStateView else {
                let emptyStateView = EmptyStateView()
                emptyStateView.tapHandler = { [weak self] in self?.emptyStateDelegate?.didTapOnEmptyStateView() }
                self.emptyStateView = emptyStateView
                return emptyStateView
            }

            return emptyStateView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyStateView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
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
                self.reloadEmptyState()
            }
        }
    }

}
