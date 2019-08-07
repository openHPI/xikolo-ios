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

        self.shadowView.layer.roundCorners(for: .default, masksToBounds: false)
    }

    func configure(_ name: String, explanation: String?, url: URL?, stateOfCertificate: String) {
        self.titleLabel.text = name
        self.descriptionLabel.text = explanation
        self.statusLabel.text = stateOfCertificate

        let achieved = url != nil
        self.isUserInteractionEnabled = achieved
        let cardColor = achieved ? Brand.default.colors.primary : ColorCompatibility.systemGray3
        self.shadowView.backgroundColor = cardColor
        self.titleLabel.backgroundColor = cardColor
        self.statusLabel.backgroundColor = cardColor
        let textColor = achieved ? UIColor.white : ColorCompatibility.label
        self.titleLabel.textColor = textColor
        self.statusLabel.textColor = textColor
    }

}

extension CertificateCell {

    static func minimalWidth(for traitCollection: UITraitCollection) -> CGFloat { // swiftlint:disable:this cyclomatic_complexity
        switch traitCollection.preferredContentSizeCategory {
        case .extraSmall:
            return 270
        case .small:
            return 280
        case .medium:
            return 290
        case .extraLarge:
            return 310
        case .extraExtraLarge:
            return 320
        case .extraExtraExtraLarge:
            return 330

        // Accessibility sizes
        case .accessibilityMedium:
            return 370
        case .accessibilityLarge:
            return 390
        case .accessibilityExtraLarge:
            return 410
        case .accessibilityExtraExtraLarge:
            return 430
        case .accessibilityExtraExtraExtraLarge:
            return 450

        default: // large
            return 300
        }
    }

}

extension CertificateCell {

    static var cardInset: CGFloat {
        return 14
    }

    static func height(for certificate: Course.Certificate, forWidth width: CGFloat, delegate: CertificateCellDelegate) -> CGFloat {
        let cardMargin = CertificateCell.cardInset
        let cardPadding: CGFloat = 16
        let cardWidth = width - 2 * cardMargin
        let textWidth = cardWidth - 2 * cardPadding

        let titleHeight = delegate.maximalHeightForTitle(withWidth: textWidth)
        let statusHeight = delegate.maximalHeightForStatus(withWidth: textWidth)
        let explanationHeight = certificate.explanation?.height(forTextStyle: .footnote, boundingWidth: cardWidth) ?? 0

        var height = cardMargin
        height += 2 * cardPadding
        height += 8
        height += 8
        height += titleHeight
        height += statusHeight
        height += explanationHeight
        height += 5

        return height
    }

    static func heightForTitle(_ title: String, withWidth width: CGFloat) -> CGFloat {
        return title.height(forTextStyle: .headline, boundingWidth: width)
    }

    static func heightForStatus(_ status: String, withWidth width: CGFloat) -> CGFloat {
        return status.height(forTextStyle: .subheadline, boundingWidth: width)
    }

}

protocol CertificateCellDelegate: AnyObject {

    func maximalHeightForTitle(withWidth width: CGFloat) -> CGFloat
    func maximalHeightForStatus(withWidth width: CGFloat) -> CGFloat

}
