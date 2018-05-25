//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class AnnouncementCell: UITableViewCell {

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.localizedFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    @IBOutlet private weak var courseLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var readStateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    @IBOutlet private var courseLabelContraints: [NSLayoutConstraint]!

    func configure(_ announcement: Announcement, showCourseTitle: Bool) {
        if UserProfileHelper.isLoggedIn, !announcement.visited {
            self.readStateLabel.textColor = Brand.Color.secondary
            self.readStateLabel.isHidden = false
            self.separatorView.isHidden = false
            self.titleLabel.textColor = .black
        } else {
            self.readStateLabel.isHidden = true
            self.separatorView.isHidden = true
            self.titleLabel.textColor = .gray
        }

        self.courseLabel.textColor = Brand.Color.secondary
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
            self.dateLabel.text = AnnouncementCell.dateFormatter.string(from: date)
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
