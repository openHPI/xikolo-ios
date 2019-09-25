//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class AnnouncementCell: UITableViewCell {

    static var dateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .none)

    @IBOutlet private weak var courseLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var readStateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    @IBOutlet private var courseLabelContraints: [NSLayoutConstraint]!

    func configure(for announcement: Announcement, showCourseTitle: Bool) {
        let userIsLoggedIn = UserProfileHelper.shared.isLoggedIn

        self.readStateLabel.textColor = Brand.default.colors.secondary
        self.readStateLabel.isHidden = !userIsLoggedIn || announcement.visited
        self.separatorView.isHidden = !userIsLoggedIn || announcement.visited

        self.titleLabel.textColor = userIsLoggedIn && announcement.visited ? ColorCompatibility.secondaryLabel : ColorCompatibility.label

        self.courseLabel.textColor = Brand.default.colors.secondary
        if let courseTitle = announcement.course?.title, showCourseTitle {
            self.courseLabel.text = courseTitle
            self.courseLabel.isHidden = false
            NSLayoutConstraint.activate(self.courseLabelContraints)
        } else {
            self.courseLabel.isHidden = true
            NSLayoutConstraint.deactivate(self.courseLabelContraints)
        }

        self.titleLabel.text = announcement.title

        if let date = announcement.publishedAt {
            self.dateLabel.text = Self.dateFormatter.string(from: date)
            self.dateLabel.isHidden = false
        } else {
            self.dateLabel.isHidden = true
            self.separatorView.isHidden = true
        }

        if let newsText = announcement.text {
            let markDown = MarkdownHelper.string(for: newsText)
            self.descriptionLabel.text = markDown.replacingOccurrences(of: "\n", with: " ")
            self.descriptionLabel.isHidden = false
        } else {
            self.descriptionLabel.isHidden = true
        }
    }

}
