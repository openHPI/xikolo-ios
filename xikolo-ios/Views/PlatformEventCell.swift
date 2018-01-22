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

    enum EventType : String {
        case pinboardAnswerComment = "pinboard.question.answer.comment.new"
        case pinboardQuestionComment = "pinboard.question.comment.new"
        case pinboardAnswer = "pinboard.question.answer.new"
        case pinboardQuestion = "pinboard.question.new"
        case pinboardDiscussionComment = "pinboard.discussion.comment.new"
        case pinboardDiscussion = "pinboard.discussion.new"
        case newsAnnoucement = "news.announcement"
        case courseAnnouncement = "course.announcement"
        case learningRoomNewFile = "learning_room.new_file"
        case learningRoomNewMembership = "learning_room.new_membership"
        case learningRoomQuitMembership = "learning_room.quit_membership"
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
            case EventType.pinboardAnswerComment.rawValue,
                 EventType.pinboardQuestionComment.rawValue,
                 EventType.pinboardAnswer.rawValue,
                 EventType.pinboardDiscussionComment.rawValue,
                 EventType.pinboardDiscussion.rawValue:
                iconName = "platform-event-icon-comment"
            case EventType.pinboardQuestion.rawValue:
                iconName = "platform-event-icon-question"
            case EventType.newsAnnoucement.rawValue,
                 EventType.courseAnnouncement.rawValue:
                iconName = "platform-event-icon-mail"
            case EventType.learningRoomNewFile.rawValue:
                iconName = "platform-event-icon-file"
            case EventType.learningRoomNewMembership.rawValue:
                iconName = "platform-event-icon-user-plus"
            case EventType.learningRoomQuitMembership.rawValue:
                iconName = "platform-event-icon-user-times"
            default:
                iconName = "platform-event-icon-mail"
            }
            categoryView.image = UIImage(named: iconName)
        }

        timelineView.backgroundColor = Brand.TintColor

    }

}
