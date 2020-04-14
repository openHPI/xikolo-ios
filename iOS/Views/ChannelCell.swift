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

        self.shadowView.addDefaultPointerInteraction()
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

    static var cardInset: CGFloat {
        return 14
    }

    static func heightForChannelList(forWidth width: CGFloat, for channel: Channel) -> CGFloat {
        let cardWidth = width - 2 * self.cardInset
        let imageHeight = min(cardWidth * 0.8, 480)

        let titleHeight = channel.title?.height(forTextStyle: .title2, boundingWidth: cardWidth) ?? 0
        let descriptionHeight = UIFont.preferredFont(forTextStyle: .subheadline).lineHeight * 3

        return self.cardInset + imageHeight + titleHeight + descriptionHeight + 8 + 4 + 4
    }

}
