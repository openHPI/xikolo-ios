//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class ChannelHeaderView: UICollectionReusableView {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var channelTeaserView: UIVisualEffectView!
    @IBOutlet private weak var playTeaserLabel: UILabel!

    weak var delegate: ChannelHeaderViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.channelTeaserView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(playChannelTeaser))
        self.channelTeaserView.addGestureRecognizer(tap)
        self.channelTeaserView.layer.roundCorners(for: .default)
        self.playTeaserLabel.text = NSLocalizedString("channel-header.play-teaser", comment: "button title for starting playback for channel teaser video")
    }

    func configure(for channel: Channel) {
        self.imageView.backgroundColor = channel.colorWithFallback(to: Brand.default.colors.window)
        self.imageView.sd_setImage(with: channel.imageURL, placeholderImage: nil)
        self.descriptionLabel.text = MarkdownHelper.string(for: channel.channelDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        self.channelTeaserView.isHidden = channel.stageStream?.hlsURL == nil
    }

    @objc private func playChannelTeaser() {
        self.delegate?.playChannelTeaser()
    }
}

extension ChannelHeaderView {

    static func height(forWidth width: CGFloat, layoutMargins: UIEdgeInsets, channel: Channel) -> CGFloat {
        let imageHeight = min(400, width * 0.8)

        let descriptionWidth = width - layoutMargins.left - layoutMargins.right
        let descriptionText = MarkdownHelper.string(for: channel.channelDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionHeight = descriptionText.height(forTextStyle: .callout, boundingWidth: descriptionWidth)

        return imageHeight + descriptionHeight + 12
    }

}

public protocol ChannelHeaderViewDelegate: AnyObject {

    func playChannelTeaser()

}
