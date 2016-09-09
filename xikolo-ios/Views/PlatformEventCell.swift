//
//  PlatformEventCell.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 06.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class PlatformEventCell: UITableViewCell {

    @IBOutlet weak var categoryView: UIImageView!
    @IBOutlet weak var titleView: UITextView!
    @IBOutlet weak var previewView: UITextView!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var timelineView: UIView!

    enum EventTypes : String {
        case PinboardAnswerComment = "pinboard.question.answer.comment.new"
        case PinboardQuestionComment = "pinboard.question.comment.new"
        case PinboardAnswer = "pinboard.question.answer.new"
        case PinboardQuestion = "pinboard.question.new"
        case PinboardDiscussionComment = "pinboard.discussion.comment.new"
        case PinboardDiscussion = "pinboard.discussion.new"
        case NewsAnnoucement = "news.announcement"
        case CourseAnnouncement = "course.announcement"
        case LearningRoomNewFile = "learning_room.new_file"
        case LearningRoomNewMembership = "learning_room.new_membership"
        case LearningRoomQuitMemebership = "learning_room.quit_membership"
    }

    func configure(platformEvent: PlatformEvent) {
        titleView.text = platformEvent.title
        previewView.text = platformEvent.preview

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        if let date = platformEvent.created_at {
            dateView.text = dateFormatter.stringFromDate(date)
        }

        switch platformEvent.type {
        default:
            categoryView.image = UIImage(named: "item-quiz-28")
        }

        timelineView.backgroundColor = Brand.TintColor

    }

}
