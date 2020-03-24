//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class MoreCell: UICollectionViewCell {

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.cardView.layer.roundCorners(for: .default)
    }

    func configure(for learningMaterialResourceType: AdditionalLearningMaterialResourceType) {
        self.cardView.backgroundColor = Brand.default.colors.window
        self.iconImageView.tintColor = ColorCompatibility.systemBackground
        self.iconImageView.image = learningMaterialResourceType.icon
        self.titleLabel.backgroundColor = Brand.default.colors.window
        self.titleLabel.textColor = ColorCompatibility.systemBackground
        self.titleLabel.text = learningMaterialResourceType.displayName
    }

    func configureNews() {
        self.cardView.backgroundColor = ColorCompatibility.secondarySystemBackground
        self.iconImageView.tintColor = ColorCompatibility.secondaryLabel

        if #available(iOS 13, *) {
            self.iconImageView.image = UIImage(systemName: "bell.circle.fill")
        } else {
            self.iconImageView.image = nil
        }

        self.titleLabel.textColor = ColorCompatibility.secondaryLabel
        self.titleLabel.text = "News"
    }

}

extension MoreCell {

    static var cardInset: CGFloat {
        return 14
    }

}

extension AdditionalLearningMaterialResourceType {

    var icon: UIImage? {
        if #available(iOS 13, *) {
             switch self {
             case .microLearning:
                return UIImage(systemName: "tv.circle.fill")
             case .podcasts:
                 return UIImage(systemName: "mic.circle")
             }
        } else {
            return nil
        }
    }
}
