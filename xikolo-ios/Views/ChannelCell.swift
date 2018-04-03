//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SDWebImage
import UIKit

class ChannelCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var moreButton: UIButton!

    func configure(_ channel: Channel) {
        self.imageView.image = nil
        //self.gradientView.isHidden = true
        self.imageView.sd_setImage(with: channel.mobileImageURL, placeholderImage: nil) { image, _, _, _ in
            //self.gradientView.isHidden = (image == nil)
        }
        titleView.text = channel.name
        descriptionView.text = channel.channelDescription

    }
}
