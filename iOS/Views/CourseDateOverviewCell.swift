//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseDateOverviewCell: UITableViewCell {

    @IBOutlet private weak var overviewContainer: UIView!
    @IBOutlet private weak var nextDateContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyCardLook(to: self.overviewContainer)
        self.applyCardLook(to: self.nextDateContainer)
    }

    private func applyCardLook(to view: UIView) {
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 6.0
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 8.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

}
