//
//  AnnouncementCell.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class AnnouncementCell : UITableViewCell {

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    @IBOutlet weak var readStateView: UIView!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func configure(_ announcement: Announcement) {
        self.readStateView.backgroundColor = Brand.TintColor
        self.readStateView.isHidden = !UserProfileHelper.isLoggedIn()
        self.readStateView.alpha = announcement.visited ? 0.0 : 1.0

        self.courseLabel.textColor = Brand.TintColorSecond
        if let courseTitle = announcement.course?.title {
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
        }

        if let newsText = announcement.text, let markDown = try? MarkdownHelper.parse(newsText).string {
            self.descriptionLabel.text = markDown.replacingOccurrences(of: "\n", with: " ")
            self.descriptionLabel.isHidden = false
        } else {
            self.descriptionLabel.isHidden = true
        }
    }

}
