//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = ColorCompatibility.secondarySystemFill
        self.textLabel?.textColor = ColorCompatibility.label
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        self.textLabel?.adjustsFontForContentSizeCategory = true
        self.textLabel?.numberOfLines = 0
        self.detailTextLabel?.textColor = ColorCompatibility.secondaryLabel
        self.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        self.detailTextLabel?.adjustsFontForContentSizeCategory = true
        self.detailTextLabel?.numberOfLines = 0

        self.isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
