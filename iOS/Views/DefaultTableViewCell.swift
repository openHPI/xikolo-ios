//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class DefaultTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        self.textLabel?.adjustsFontForContentSizeCategory = true
        self.textLabel?.numberOfLines = 0

        self.addDefaultPointerInteraction()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
