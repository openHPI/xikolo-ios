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

    @IBOutlet private weak var cardView: InnerShadowView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionLabel: UILabel!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.cardView.layer.cornerRadius = 6
        self.cardView.layer.masksToBounds = true
        self.actionLabel.textColor = Brand.default.colors.window
        self.bottomConstraint.constant = Brand.default.features.showCourseTeachers ? 54.5 : 35.5
    }

    func configure(for style: Style, configuration: CourseOverviewCell.Configuration) {
        switch (style, configuration) {
        case (.emptyCourseOverview, .currentCourses):
            self.messageLabel.text = "You are enrolled in no courses yet"
            self.actionLabel.text = "Discover available courses"
        case (.emptyCourseOverview, .completedCourses):
            self.messageLabel.text = "You haven't completed any courses yet"
            self.actionLabel.text = "Discover available courses"
        case (.showAllCoursesOfOverview, .currentCourses):
            self.messageLabel.text = nil
            self.actionLabel.text = "Show all current courses"
        case (.showAllCoursesOfOverview, .completedCourses):
            self.messageLabel.text = nil
            self.actionLabel.text = "Show all completed courses"
        }
    }

}
