//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class PseudoCourseCell: UICollectionViewCell {

    enum Style {
        case emptyCourseOverview
        case showAllCoursesOfOverview
    }

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionLabel: UILabel!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.cardView.layer.roundCorners(for: .default, masksToBounds: false)
        self.actionLabel.textColor = Brand.default.colors.window
    }

    func configure(for style: Style, configuration: CourseListConfiguration) {
        switch (style, configuration) {
        case (.emptyCourseOverview, .currentCourses):
            self.messageLabel.text = NSLocalizedString("dashboard.course-overview.no-courses.current.message",
                                                       comment: "message text for course overview with no current courses")
            self.actionLabel.text = NSLocalizedString("dashboard.course-overview.no-courses.action",
                                                      comment: "action text for course overview with no courses")
        case (.emptyCourseOverview, .completedCourses):
            self.messageLabel.text = NSLocalizedString("dashboard.course-overview.no-courses.completed.message",
                                                       comment: "message text for course overview with no completed courses")
            self.actionLabel.text = NSLocalizedString("dashboard.course-overview.no-courses.action",
                                                      comment: "action text for course overview with no courses")
        case (.showAllCoursesOfOverview, .currentCourses):
            self.messageLabel.text = nil
            self.actionLabel.text = NSLocalizedString("dashboard.course-overview.show-all-courses.current.action",
                                                      comment: "action text for showing all current courses")
        case (.showAllCoursesOfOverview, .completedCourses):
            self.messageLabel.text = nil
            self.actionLabel.text = NSLocalizedString("dashboard.course-overview.show-all-courses.completed.action",
                                                      comment: "action text for showing all completed courses")
        default:
            self.messageLabel.text = nil
            self.actionLabel.text = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.bottomConstraint.constant = CourseCell.cardBottomOffsetForOverviewList
    }

}
