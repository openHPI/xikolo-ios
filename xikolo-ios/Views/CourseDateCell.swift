//
//  CourseDateCell.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 17.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import UIKit

class CourseDateCell : UITableViewCell {

    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dateHighlightView: UIView!

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    static let timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    func configure(_ courseDate: CourseDate) {
        self.courseLabel.textColor = Brand.TintColorSecond
        if let courseName = courseDate.course?.title {
            self.courseLabel.text = courseName
            self.courseLabel.isHidden = false
        } else {
            self.courseLabel.isHidden = true
        }

        self.titleLabel.text = courseDate.title

        switch courseDate.type {
        case "item_submission_deadline"?:
            self.dateHighlightView.backgroundColor = Brand.TintColorThird
            self.dateLabel.textColor = UIColor.white
            self.timeLabel.textColor = UIColor.white
        case "course_start"?:
            self.titleLabel.text = NSLocalizedString("course-date-cell.course-start.title",
                                               comment: "specfic title for course start in a course date cell")
        default:
            self.dateHighlightView.backgroundColor = nil
            self.dateLabel.textColor = UIColor.darkGray
            self.timeLabel.textColor = UIColor.darkGray
        }

        if let date = courseDate.date {
            self.dateLabel.text = CourseDateCell.dateFormatter.string(from: date)
            self.timeLabel.text = CourseDateCell.timeFormatter.string(from: date)
            self.timeLabel.isHidden = false
        } else {
            self.dateLabel.text = "Unknown"
            self.timeLabel.isHidden = true
        }

    }
    
}
