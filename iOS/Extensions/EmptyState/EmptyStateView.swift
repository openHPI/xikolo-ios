//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

final class EmptyStateView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.detailLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill

        if #available(iOS 11, *) {
            stackView.spacing = UIStackView.spacingUseSystem
        } else {
            stackView.spacing = 16
        }

        return stackView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCompatibility.secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCompatibility.secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.addSubview(self.stackView)

        let centerYConstraint = NSLayoutConstraint(item: self.stackView,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerY,
                                                   multiplier: 2/3,
                                                   constant: 0)

        if #available(iOS 11, *) {
            NSLayoutConstraint.activate([
                centerYConstraint,
                self.stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1),
                self.stackView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.trailingAnchor, multiplier: 1),
            ])
        } else {
            NSLayoutConstraint.activate([
                centerYConstraint,
                self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 16),
            ])
        }
    }

}
