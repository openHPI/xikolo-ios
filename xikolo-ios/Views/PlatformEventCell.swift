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

    func configure(_ platformEvent: PlatformEvent) {
        titleView.text = platformEvent.title
        previewView.text = platformEvent.preview

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        if let date = platformEvent.createdAt {
            dateView.text = dateFormatter.string(from: date)
        }

        if let type = platformEvent.type {
            let iconName: String
            switch type {
            case EventTypes.PinboardAnswerComment.rawValue,
                 EventTypes.PinboardQuestionComment.rawValue,
                 EventTypes.PinboardAnswer.rawValue,
                 EventTypes.PinboardDiscussionComment.rawValue,
                 EventTypes.PinboardDiscussion.rawValue:
                iconName = "events-comment-22"
            case EventTypes.PinboardQuestion.rawValue:
                iconName = "events-question-22"
            case EventTypes.NewsAnnoucement.rawValue,
                 EventTypes.CourseAnnouncement.rawValue:
                iconName = "events-mail-22"
            case EventTypes.LearningRoomNewFile.rawValue:
                iconName = "events-file-22"
            case EventTypes.LearningRoomNewMembership.rawValue:
                iconName = "events-user-plus-22"
            case EventTypes.LearningRoomQuitMemebership.rawValue:
                iconName = "events-user-times-22"
            default:
                iconName = "events-mail-22"
            }
            categoryView.image = UIImage(named: iconName)
        }

        timelineView.backgroundColor = Brand.TintColor

    }

}
