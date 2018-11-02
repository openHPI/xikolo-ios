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
        self.shadowView.backgroundColor = achieved ? Brand.default.colors.primary : UIColor.lightGray
        self.titleLabel.backgroundColor = self.shadowView.backgroundColor
        self.statusLabel.backgroundColor = self.shadowView.backgroundColor
        self.titleLabel.textColor = achieved ? UIColor.white : UIColor.darkText
    }

}
