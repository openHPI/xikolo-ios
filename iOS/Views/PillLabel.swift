//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class PillLabel: UILabel {

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        let newWidth = superSize.width + superSize.height
        return CGSize(width: newWidth, height: superSize.height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setup()
    }

    private func setup() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = self.layer.cornerRadius > 0
        self.textAlignment = .center
    }

}
