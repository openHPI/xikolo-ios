//
//  AnnouncementCell.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class AnnouncementCell : UITableViewCell {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var readStateView: UIView!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var courseView: UILabel!
    @IBOutlet weak var roundedTagBackgroundView: UIView!

    func configure(_ announcement: Announcement) {
        readStateView.backgroundColor = Brand.TintColor

        descriptionView.isScrollEnabled = false
        descriptionView.textContainer.maximumNumberOfLines = 4
        descriptionView.textContainer.lineBreakMode = .byTruncatingTail

        if let date = announcement.publishedAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateView.text = dateFormatter.string(from: date)
        }

        titleView.text = announcement.title

        if let newsText = announcement.text {
            let markDown = try? MarkdownHelper.parse(newsText) // TODO: Error handling
            self.descriptionView.attributedText = markDown
        }
        readStateView.isHidden = !UserProfileHelper.isLoggedIn() || announcement.visited

        roundedTagBackgroundView.isHidden = announcement.course == nil
        courseView.text = announcement.course?.title
    }

}
