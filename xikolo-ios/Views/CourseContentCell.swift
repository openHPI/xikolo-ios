//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseContentCell: UICollectionViewCell {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var hightlightView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleView.textColor = .lightGray
        self.hightlightView.backgroundColor = Brand.Color.primary
        self.hightlightView.isHidden = true
        self.hightlightView.layer.cornerRadius = self.hightlightView.bounds.height / 2
        self.hightlightView.clipsToBounds = true
    }

    func configure(for content: CourseContent, isSelected: Bool) {
        self.titleView.text = content.title
        self.markAsSelected(isSelected)

    }

    func markAsSelected(_ isSeleted: Bool) {
        self.titleView.textColor = isSelected ? UIColor.black : UIColor.lightGray
        self.titleView.font = isSelected ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        self.hightlightView.isHidden = !isSelected
    }

}
