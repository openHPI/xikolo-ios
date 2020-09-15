//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

@available(iOS 11, *)
extension NSDirectionalEdgeInsets {

    static func customInsets(for viewController: UIViewController) -> NSDirectionalEdgeInsets {
        return self.customInsets(for: viewController.view,
                                 traitCollection: viewController.traitCollection,
                                 minimumInsets: viewController.systemMinimumLayoutMargins)
    }

    static func customInsets(
        for view: UIView,
        traitCollection: UITraitCollection,
        minimumInsets: NSDirectionalEdgeInsets = .zero
    ) -> NSDirectionalEdgeInsets {
        var minimumLeadingInset = minimumInsets.leading
        var minimumTrailingInset = minimumInsets.trailing

        if traitCollection.horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad {
            minimumLeadingInset = max(48, minimumLeadingInset)
            minimumTrailingInset = max(48, minimumTrailingInset)
        }

        let minimumInsets = NSDirectionalEdgeInsets(top: 0, leading: minimumLeadingInset, bottom: 0, trailing: minimumTrailingInset)

        return self.insets(for: view.bounds.size, traitCollection: traitCollection, factor: 0.5, minimumInsets: minimumInsets)
    }

    static func readableContentInsets(for viewController: UIViewController) -> NSDirectionalEdgeInsets {
        return self.readableContentInsets(for: viewController.view,
                                          traitCollection: viewController.traitCollection,
                                          minimumInsets: viewController.systemMinimumLayoutMargins)
    }

    static func readableContentInsets(
        for view: UIView,
        traitCollection: UITraitCollection,
        minimumInsets: NSDirectionalEdgeInsets = .zero
    ) -> NSDirectionalEdgeInsets {
        return self.insets(for: view.bounds.size, traitCollection: traitCollection, factor: 1, minimumInsets: minimumInsets)
    }

    private static func insets(
        for size: CGSize,
        traitCollection: UITraitCollection,
        factor: CGFloat,
        minimumInsets: NSDirectionalEdgeInsets = .zero
    ) -> NSDirectionalEdgeInsets {
        let readableWidth = self.readableWidth(for: traitCollection) ?? size.width
        let remainingWidth = size.width - readableWidth
        let padding = remainingWidth / 2 * factor

        return NSDirectionalEdgeInsets(
            top: 0,
            leading: max(padding, minimumInsets.leading),
            bottom: 0,
            trailing: max(padding, minimumInsets.trailing)
        )
    }

    // swiftlint:disable:next cyclomatic_complexity
    private static func readableWidth(for traitCollection: UITraitCollection) -> CGFloat? {
        guard traitCollection.horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad else { return nil }

        switch traitCollection.preferredContentSizeCategory {
        case .extraSmall:
            return 560
        case .small:
            return 600
        case .medium:
            return 632
        case .large:
            return 672
        case .extraLarge:
            return 744
        case .extraExtraLarge:
            return 824
        case .extraExtraExtraLarge:
            return 896
        case .accessibilityMedium:
            return 1088
        case .accessibilityLarge:
            return 1400
        case .accessibilityExtraLarge:
            return 1500
        case .accessibilityExtraExtraLarge:
            return 1600
        case .accessibilityExtraExtraExtraLarge:
            return 1700
        default:
            return nil
        }
    }

}
