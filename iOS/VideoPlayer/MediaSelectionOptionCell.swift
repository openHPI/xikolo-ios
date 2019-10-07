//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class MediaSelectionOptionCell: UITableViewCell {

    static let identifier = "MediaSelectionOptionCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.textLabel?.textColor = .white
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        self.textLabel?.adjustsFontForContentSizeCategory = true
        self.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        self.tintColor = .white
        self.selectionStyle = .none
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
        let pointSize = UIFont.preferredFont(forTextStyle: .body).pointSize
        let weight: UIFont.Weight = selected ? .bold : .regular
        self.textLabel?.font = UIFont.systemFont(ofSize: pointSize, weight: weight)
    }

}
