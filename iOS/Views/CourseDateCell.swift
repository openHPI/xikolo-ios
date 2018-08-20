//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation
import UIKit

class CourseDateCell: UITableViewCell {

    @IBOutlet private var courseLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.courseLabel.textColor = Brand.default.colors.secondary
    }

    func configure(_ courseDate: CourseDate) {
        self.dateLabel.text = courseDate.defaultDateString
        self.courseLabel.text = courseDate.course?.title
        self.titleLabel.text = courseDate.contextAwareTitle
    }

}
