//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class PseudoCourseCell: UICollectionViewCell {

    enum Style {
        case emptyCourseOverview
    }

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionLabel: UILabel!

    override var isAccessibilityElement: Bool {
        get { true }
        set {}
    }

    override var accessibilityLabel: String? {
        get {
            let labels = [self.messageLabel, self.actionLabel].compactMap { $0 }
            return labels.compactMap(\.accessibilityLabel).joined(separator: ", ")
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get { .button }
        set {}
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.cardView.layer.roundCorners(for: .default, masksToBounds: false)
        self.actionLabel.textColor = Brand.default.colors.window

        self.cardView.addDefaultPointerInteraction()
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
        default:
            self.messageLabel.text = nil
            self.actionLabel.text = nil
        }
    }

    static func heightForOverviewList(forWidth width: CGFloat) -> CGFloat {
        // All values were taken from Interface Builder
        var height: CGFloat = 12 // top padding
        height += width / 2 // box/image
        height += 8 // top padding
        return height
    }

}
