//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class AdditionalLearningMaterialCell: UICollectionViewCell {

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

        self.cardView.addDefaultPointerInteraction()
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

    func configure(for learningMaterial: AdditionalLearningMaterial) {
        self.cardView.backgroundColor = Brand.default.colors.window
        self.iconImageView.tintColor = ColorCompatibility.systemBackground.withAlphaComponent(0.95)
        self.iconImageView.image = learningMaterial.imageName.flatMap(UIImage.init(named:))
        self.titleLabel.textColor = ColorCompatibility.systemBackground.withAlphaComponent(0.95)
        self.titleLabel.text = learningMaterial.title
    }

}

extension AdditionalLearningMaterialCell {

    static var cardInset: CGFloat {
        return 8
    }

}
