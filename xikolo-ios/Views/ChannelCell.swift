//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SDWebImage
import UIKit

class ChannelCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isAccessibilityElement = true

        self.imageView.layer.cornerRadius = 4.0
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.imageView.layer.borderWidth = 0.5
        self.imageView.backgroundColor = Brand.TintColorSecond

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.gradientView.frame.size.width, height: self.gradientView.frame.size.height)
        self.gradientView.layer.insertSublayer(gradient, at: 0)
        self.gradientView.layer.cornerRadius = 4.0
        self.gradientView.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientView.layer.sublayers?.first?.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.gradientView.frame.size.height)
    }

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
