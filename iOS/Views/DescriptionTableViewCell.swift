//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    private let decorativeImageView1 = UIImageView()
    private let decorativeImageView2 = UIImageView()
    private let decorativeImageView3 = UIImageView()

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = ColorCompatibility.label
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = ColorCompatibility.secondaryLabel
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        return descriptionLabel
    }()

    var decorativeImages: (UIImage?, UIImage?, UIImage?) {
        get {
            return (
                self.decorativeImageView1.image,
                self.decorativeImageView2.image,
                self.decorativeImageView3.image
            )
        }
        set {
            self.decorativeImageView1.image = newValue.0
            self.decorativeImageView2.image = newValue.1
            self.decorativeImageView3.image = newValue.2
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let innerStackView = UIStackView(arrangedSubviews: [self.decorativeImageView1, self.decorativeImageView2, self.decorativeImageView3])
        innerStackView.axis = .horizontal
        innerStackView.alignment = .center
        innerStackView.spacing = 8

        let stackView = UIStackView(arrangedSubviews: [innerStackView, self.titleLabel, self.descriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.setCustomSpacing(8, after: self.titleLabel)
        self.contentView.addSubview(stackView)


        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor, constant: -8),
        ])

        self.addDefaultPointerInteraction()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
