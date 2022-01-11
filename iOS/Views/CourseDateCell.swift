//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation
import UIKit

class CourseDateCell: UITableViewCell {

    private static let courseDateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .long)

    @IBOutlet private var courseLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.courseLabel.textColor = Brand.default.colors.secondary

        self.addDefaultPointerInteraction()
    }

    func configure(for courseDate: CourseDate, inCourseContext: Bool) {
        self.dateLabel.text = courseDate.date.map(Self.courseDateFormatter.string(from:))
        self.courseLabel.text = courseDate.course?.title
        self.courseLabel.isHidden = inCourseContext
        self.titleLabel.text = courseDate.contextAwareTitle
        self.accessoryType = inCourseContext ? .none : .disclosureIndicator
    }

}
