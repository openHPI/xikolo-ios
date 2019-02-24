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

    override var isSelected: Bool {
        didSet {
            self.titleLabel.textColor = self.isSelected ? UIColor.white : UIColor.lightGray
            self.layer.backgroundColor = self.isSelected ? Brand.default.colors.window.cgColor : UIColor.white.cgColor
            self.backgroundColor = self.isSelected ? Brand.default.colors.window : UIColor.white
            self.layer.borderColor = self.isSelected ? Brand.default.colors.window.cgColor : UIColor.lightGray.cgColor
        }
    }

    static func size(forTitle title: String) -> CGSize {
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

}
