//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import Binge
import Common
import CoreData
import UIKit

class ChannelHeaderView: UICollectionReusableView {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var channelTeaserView: UIVisualEffectView!

    weak var delegate: BingePlayerDelegate?
    var channelTeaserUrl: URL?

    override func awakeFromNib() {
        super.awakeFromNib()
        channelTeaserView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.channelTeaserView.addGestureRecognizer(tap)
    }

    func configure(for channel: Channel) {

        self.imageView.backgroundColor = channel.colorWithFallback(to: Brand.default.colors.window)
        self.imageView.sd_setImage(with: channel.imageURL, placeholderImage: nil)
        self.descriptionLabel.text = MarkdownHelper.string(for: channel.channelDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        self.channelTeaserView.isHidden = true

        guard let stageStream = channel.stageStream else { return }
        _ = stageStream
        guard let url = channel.stageStream?.hlsURL else { return }
        self.channelTeaserUrl = url

        self.channelTeaserView.isHidden = false
        self.channelTeaserView.layer.roundCorners(for: .default)

    }

    @objc private func tapped() {
        print("tapped")
        guard let url = self.channelTeaserUrl else { return }
        delegate?.didTapPlay(url: url)
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
