//
//  Created for xikolo-ios under GPL-3.0 license.
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

    var tapHandler: (() -> Void)?

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.preservesSuperviewLayoutMargins = true
        self.addSubview(self.stackView)

        let centerYConstraint = NSLayoutConstraint(item: self.stackView,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerY,
                                                   multiplier: 2 / 3,
                                                   constant: 0)

        NSLayoutConstraint.activate([
            centerYConstraint,
            self.stackView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 0),
            self.stackView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: 0),
        ])

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(gestureRecognizer)
    }

    @objc func handleTap() {
        self.tapHandler?()
    }

}
