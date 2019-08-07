//
//  Created for xikolo-ios under MIT license.
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
        self.layer.roundCorners(for: .default)

        self.titleLabel.font = CourseSearchFilterCell.titleFont

        if #available(iOS 13, *) {
            self.titleLabel.textColor = .secondaryLabel
            self.traitCollection.performAsCurrent {
                self.layer.borderColor = UIColor.secondaryLabel.cgColor
            }
        } else {
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.titleLabel.textColor = .lightGray
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.frame.size = self.contentView.systemLayoutSizeFitting(layoutAttributes.size)
        return layoutAttributes
    }

    func configure(for filter: CourseSearchFilter, with selectedOptions: Set<String>?) {
        let isNormalState = selectedOptions?.isEmpty ?? true
        self.configureAppearance(normalState: isNormalState)
        self.titleLabel.text = CourseSearchFilterCell.title(for: filter, with: selectedOptions)
    }

    func configureForClearButton() {
        self.configureAppearance(normalState: true)
        self.titleLabel.text = NSLocalizedString("course-list.search.filter.clear", comment: "Title for button for clearning all filters")
    }

    private func configureAppearance(normalState: Bool) {
        if #available(iOS 13, *) {
            self.titleLabel.textColor = normalState ? UIColor.secondaryLabel : UIColor.systemBackground
            self.traitCollection.performAsCurrent {
                self.layer.backgroundColor = normalState ? UIColor.systemBackground.cgColor : Brand.default.colors.window.cgColor
                self.layer.borderColor = normalState ? UIColor.secondaryLabel.cgColor : Brand.default.colors.window.cgColor
            }
        } else {
            self.titleLabel.textColor = normalState ? UIColor.lightGray : UIColor.white
            self.layer.backgroundColor = normalState ? UIColor.white.cgColor : Brand.default.colors.window.cgColor
            self.layer.borderColor = normalState ? UIColor.lightGray.cgColor : Brand.default.colors.window.cgColor
        }
    }

    static func cellHeight() -> CGFloat {
        return CourseSearchFilterCell.titleFont.lineHeight + 2 * CourseSearchFilterCell.padding + 2
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
