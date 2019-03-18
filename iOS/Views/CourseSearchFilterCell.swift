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

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true

        self.titleLabel.textColor = .lightGray
        self.titleLabel.font = CourseSearchFilterCell.titleFont
    }

    func configure(for filter: CourseSearchFilter, with selectedOptions: Set<String>?) {
        let isNormalState = selectedOptions?.isEmpty ?? true
        self.titleLabel.text = CourseSearchFilterCell.title(for: filter, with: selectedOptions)
        self.titleLabel.textColor = isNormalState ? UIColor.lightGray :  UIColor.white
        #warning("twice?")
        self.layer.backgroundColor = isNormalState ? UIColor.white.cgColor : Brand.default.colors.window.cgColor
        self.backgroundColor = isNormalState ? UIColor.white : Brand.default.colors.window
        self.layer.borderColor = isNormalState ? UIColor.lightGray.cgColor : Brand.default.colors.window.cgColor
    }

    static func size(for filter: CourseSearchFilter, with selectedOptions: Set<String>?) -> CGSize {
        let title = self.title(for: filter, with: selectedOptions)
        let fontHeight = CourseSearchFilterCell.titleFont.lineHeight

        let boundingSize = CGSize(width: CGFloat.infinity, height: fontHeight)
        let titleAttributes = [NSAttributedString.Key.font: CourseSearchFilterCell.titleFont]
        let titleSize = NSString(string: title).boundingRect(with: boundingSize,
                                                             options: .usesLineFragmentOrigin,
                                                             attributes: titleAttributes,
                                                             context: nil)

        return CGSize(width: titleSize.width + 2 * CourseSearchFilterCell.padding + 2,
                      height: fontHeight + 2 * CourseSearchFilterCell.padding)
    }

    private static func title(for filter: CourseSearchFilter, with selectedOptions: Set<String>?) -> String {
        if let options = selectedOptions, !options.isEmpty {
            return "\(filter.title) · \(options.count)"
        } else {
            return filter.title
        }
    }

}
