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
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        let cornerRadius: CGFloat = 6.0
        self.shadowView.layer.cornerRadius = cornerRadius
    }

    func configure(_ name: String, explanation: String?, url: URL?, stateOfCertificate: String) {
        self.titleLabel.text = name
        self.descriptionLabel.text = explanation
        self.statusLabel.text = stateOfCertificate

        let achieved = url != nil
        self.isUserInteractionEnabled = achieved
        let cardColor = achieved ? Brand.default.colors.primary : UIColor(white: 0.75, alpha: 1.0)
        self.shadowView.backgroundColor = cardColor
        self.titleLabel.backgroundColor = cardColor
        self.statusLabel.backgroundColor = cardColor
        let textColor = achieved ? UIColor.white : UIColor.darkText
        self.titleLabel.textColor = textColor
        self.statusLabel.textColor = textColor
    }

}
