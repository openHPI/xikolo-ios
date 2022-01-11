//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseSearchFilterCell: UICollectionViewCell {

    private static let padding: CGFloat = 8
    private static var titleFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .callout)
    }

    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.borderWidth = 1
        self.layer.roundCorners(for: .searchField)

        self.titleLabel.font = Self.titleFont
        self.titleLabel.textColor = ColorCompatibility.secondaryLabel

        self.traitCollection.performAsCurrent {
            self.layer.borderColor = ColorCompatibility.separator.cgColor
        }

        self.addDefaultPointerInteraction()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.frame.size = self.contentView.systemLayoutSizeFitting(layoutAttributes.size)
        return layoutAttributes
    }

    func configure(for filter: CourseSearchFilter, with selectedOptions: Set<String>?) {
        let isHighlighted = !(selectedOptions?.isEmpty ?? true)
        self.layer.backgroundColor = isHighlighted ? Brand.default.colors.window.cgColor : UIColor.clear.cgColor
        self.layer.borderColor = isHighlighted ? Brand.default.colors.window.cgColor : ColorCompatibility.separator.cgColor
        self.titleLabel.textColor = isHighlighted ? ColorCompatibility.systemBackground : ColorCompatibility.secondaryLabel
        self.titleLabel.text = Self.title(for: filter, with: selectedOptions)
    }

    func configureForClearButton() {
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.borderColor = UIColor.clear.cgColor
        self.titleLabel.textColor = ColorCompatibility.secondaryLabel
        self.titleLabel.text = NSLocalizedString("course-list.search.filter.clear", comment: "Title for button for clearing all filters")
    }

    static var cellHeight: CGFloat {
        return Self.titleFont.lineHeight + 2 * Self.padding + 2
    }

    private static func title(for filter: CourseSearchFilter, with selectedOptions: Set<String>?) -> String? {
        guard let options = selectedOptions, !options.isEmpty else {
            return filter.title
        }

        guard let title = filter.title else {
            return String(options.count)
        }

        return "\(title) · \(options.count)"
    }

}
