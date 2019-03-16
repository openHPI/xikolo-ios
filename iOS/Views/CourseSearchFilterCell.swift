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

    func configure(for filterType: CourseSearchFilterType, with filter: CourseSearchFilter?) {
        self.titleLabel.text = CourseSearchFilterCell.title(for: filterType, with: filter)
        self.titleLabel.textColor = filter == nil ? UIColor.lightGray :  UIColor.white
        #warning("twice?")
        self.layer.backgroundColor = filter == nil ? UIColor.white.cgColor : Brand.default.colors.window.cgColor
        self.backgroundColor = filter == nil ? UIColor.white : Brand.default.colors.window
        self.layer.borderColor = filter == nil ? UIColor.lightGray.cgColor : Brand.default.colors.window.cgColor
    }

    static func size(for filterType: CourseSearchFilterType, with filter: CourseSearchFilter?) -> CGSize {
        let title = self.title(for: filterType, with: filter)
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

    private static func title(for filterType: CourseSearchFilterType, with filter: CourseSearchFilter?) -> String {
        var title = filterType.title

        if let counterValue = filter?.counterValue {
            title += " · \(counterValue)"
        }

        return title
    }

}
