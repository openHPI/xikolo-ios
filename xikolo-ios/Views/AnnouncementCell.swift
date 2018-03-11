//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class AnnouncementCell : UITableViewCell {

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

    func configure(_ announcement: Announcement, showCourseTitle: Bool) {
        if UserProfileHelper.isLoggedIn(), !announcement.visited {
            self.readStateLabel.textColor = Brand.TintColorSecond
            self.readStateLabel.isHidden = false
            self.separatorView.isHidden = false
            self.titleLabel.textColor = .black
        } else {
            self.readStateLabel.isHidden = true
            self.separatorView.isHidden = true
            self.titleLabel.textColor = .gray
        }

        self.courseLabel.textColor = Brand.TintColorSecond
        if let courseTitle = announcement.course?.title, showCourseTitle {
            self.courseLabel.text = courseTitle
            self.courseLabel.isHidden = false
        } else {
            self.courseLabel.isHidden = true
        }

        self.titleLabel.text = announcement.title

        if let date = announcement.publishedAt {
            self.dateLabel.text = AnnouncementCell.dateFormatter.string(from: date)
            self.dateLabel.isHidden = false
        } else {
            self.dateLabel.isHidden = true
            self.separatorView.isHidden = true
        }

        if let newsText = announcement.text, let markDown = try? MarkdownHelper.parse(newsText).string {
            self.descriptionLabel.text = markDown.replacingOccurrences(of: "\n", with: " ")
            self.descriptionLabel.isHidden = false
        } else {
            self.descriptionLabel.isHidden = true
        }
    }

}
