//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SDWebImage
import UIKit

class ChannelCell: UICollectionViewCell {

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var channelImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.shadowView.layer.roundCorners(for: .default, masksToBounds: false)

        self.channelImage.layer.roundCorners(for: .default)
        self.channelImage.backgroundColor = Brand.default.colors.secondary
    }

    func configure(_ channel: Channel) {
        self.channelImage.image = nil // Avoid old images on cell reuse when new image can not be loaded
        self.channelImage.sd_setImage(with: channel.imageURL, placeholderImage: nil)

        self.titleLabel.text = channel.title
        self.titleLabel.textColor = channel.colorWithFallback(to: ColorCompatibility.label)

        let markDown = MarkdownHelper.string(for: channel.channelDescription ?? "")
        self.descriptionLabel.text = markDown.replacingOccurrences(of: "\n", with: " ")
    }

}

extension ChannelCell {

    // TODO: test on ipad
    static func minimalWidth(for traitCollection: UITraitCollection) -> CGFloat { // swiftlint:disable:this cyclomatic_complexity
        switch traitCollection.preferredContentSizeCategory {
        case .extraSmall:
            return 280
        case .small:
            return 290
        case .medium:
            return 300
        case .extraLarge:
            return 320
        case .extraExtraLarge:
            return 330
        case .extraExtraExtraLarge:
            return 340

        // Accessibility sizes
        case .accessibilityMedium:
            return 360
        case .accessibilityLarge:
            return 380
        case .accessibilityExtraLarge:
            return 400
        case .accessibilityExtraExtraLarge:
            return 420
        case .accessibilityExtraExtraExtraLarge:
            return 440

        default: // large
            return 310
        }
    }

}

extension ChannelCell {

    static var cardInset: CGFloat {
        return 14
    }

    static func heightForChannelList(forWidth width: CGFloat, for channel: Channel) -> CGFloat {
        let cardWidth = width - 2 * self.cardInset
        let imageHeight = cardWidth * 0.8

        let titleHeight = channel.title?.height(forTextStyle: .title2, boundingWidth: cardWidth) ?? 0
        let descriptionHeight = UIFont.preferredFont(forTextStyle: .subheadline).lineHeight * 3

        return self.cardInset + imageHeight + titleHeight + descriptionHeight + 8 + 4 + 4
    }

}
