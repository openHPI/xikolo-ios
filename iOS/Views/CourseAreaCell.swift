//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseAreaCell: UICollectionViewCell {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var hightlightView: UIView!

    override var isSelected: Bool {
        didSet {
            self.titleView.textColor = self.isSelected ? UIColor.black : UIColor.lightGray
            self.titleView.font = self.isSelected ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
            self.hightlightView.isHidden = !self.isSelected
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleView.textColor = .lightGray
        self.hightlightView.backgroundColor = Brand.default.colors.primary
        self.hightlightView.isHidden = true
        self.hightlightView.layer.cornerRadius = self.hightlightView.bounds.height / 2
        self.hightlightView.clipsToBounds = true
    }

    func configure(for content: CourseArea) {
        self.titleView.text = content.title
    }

}
