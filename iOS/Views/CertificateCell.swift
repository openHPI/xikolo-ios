//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SDWebImage
import UIKit

class CertificateCell: UICollectionViewCell {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cornerRadius: CGFloat = 6.0
        self.shadowView.layer.cornerRadius = cornerRadius

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.3).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.gradientView.frame.size.width, height: self.gradientView.frame.size.height)
        self.gradientView.layer.insertSublayer(gradient, at: 0)
        self.gradientView.layer.cornerRadius = cornerRadius
        self.gradientView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientView.layer.sublayers?.first?.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.gradientView.frame.size.height)
    }
    
    func configure(_ certificate: (name: String, explanation: String?, url: URL?), stateOfCertificate: String) {
        self.titleLabel.text = certificate.name
        self.descriptionLabel.text = certificate.explanation
        self.statusLabel.text = stateOfCertificate
        
        let achieved = certificate.url != nil
        self.isUserInteractionEnabled = achieved
        self.shadowView.backgroundColor = achieved ? Brand.default.colors.primary : UIColor(red: 214 / 255, green: 214 / 255, blue: 214 / 255, alpha: 1)
        self.titleLabel.textColor = achieved ? UIColor.white : UIColor(red: 94 / 255, green: 94 / 255, blue: 94 / 255, alpha: 1)
    }
    
}
