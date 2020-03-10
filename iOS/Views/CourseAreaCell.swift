//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseAreaCell: UICollectionViewCell {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var hightlightView: UIView!

    static func font(whenSelected selected: Bool) -> UIFont {
        let preferredFontSize = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
        return selected ? UIFont.boldSystemFont(ofSize: preferredFontSize) : UIFont.systemFont(ofSize: preferredFontSize)
    }

    override var isSelected: Bool {
        didSet {
            self.titleView.font = Self.font(whenSelected: self.isSelected)
            self.titleView.textColor = self.isSelected ? ColorCompatibility.label : ColorCompatibility.secondaryLabel
            self.hightlightView.layer.roundCorners(for: .default)
            self.hightlightView.isHidden = !self.isSelected
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleView.textColor = ColorCompatibility.secondaryLabel
        self.hightlightView.isHidden = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.titleView.font = Self.font(whenSelected: self.isSelected)
    }

    func configure(for content: CourseArea) {
        self.titleView.text = content.title
    }

}
