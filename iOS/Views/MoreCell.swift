//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class MoreCell: UICollectionViewCell {

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: -1, y: -1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.colors = [UIColor.clear.cgColor, ColorCompatibility.systemBackground.withAlphaComponent(0.2).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.gradientView.frame.size.width, height: self.gradientView.frame.size.height)
        return gradient
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.cardView.layer.roundCorners(for: .default)
        self.gradientView.layer.insertSublayer(self.gradientLayer, at: 0)
        self.gradientView.layer.roundCorners(for: .default)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientView.layer.sublayers?.first?.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.gradientView.frame.size.height)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.gradientLayer.colors = [UIColor.clear.cgColor, ColorCompatibility.systemBackground.withAlphaComponent(0.2).cgColor]
            }
        }
    }

    func configure(for learningMaterialResourceType: AdditionalLearningMaterialResourceType) {
        self.cardView.backgroundColor = Brand.default.colors.window
        self.iconImageView.tintColor = ColorCompatibility.systemBackground.withAlphaComponent(0.95)
        self.iconImageView.image = learningMaterialResourceType.icon
        self.titleLabel.textColor = ColorCompatibility.systemBackground.withAlphaComponent(0.95)
        self.titleLabel.text = learningMaterialResourceType.displayName
    }

    func configureNews() {
        self.cardView.backgroundColor = ColorCompatibility.secondarySystemBackground
        self.iconImageView.tintColor = ColorCompatibility.secondaryLabel
        self.iconImageView.image =  R.image.more.news()
        self.titleLabel.textColor = ColorCompatibility.secondaryLabel
        self.titleLabel.text = NSLocalizedString("additional-learning-material.dummy.news.title",
                                                 comment: "Display name for additional learning material dummy: news")
    }

}

extension MoreCell {

    static var cardInset: CGFloat {
        return 14
    }

}

extension AdditionalLearningMaterialResourceType {

    var icon: UIImage? {
        switch self {
        case .microLearning:
            return R.image.more.microLearning()
        case .podcasts:
            return R.image.more.podcasts()
        }
    }
}
