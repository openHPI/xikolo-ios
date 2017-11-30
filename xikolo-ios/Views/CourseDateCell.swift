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

    @IBOutlet var titleView: UILabel!
    @IBOutlet var detailView: UILabel!
    @IBOutlet var dateHighlightView: UIView!

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    func configure(_ courseDate: CourseDate) {
        titleView.text = courseDate.title
        switch courseDate.type {
        case "item_submission_deadline"?:
            dateHighlightView.backgroundColor = Brand.TintColorThird
            detailView.textColor = UIColor.white
        case "course_start"?:
            titleView.text = NSLocalizedString("course-date-cell.course-start.title",
                                               comment: "specfic title for course start in a course date cell")
        default:
            dateHighlightView.backgroundColor = UIColor.white
            detailView.textColor = UIColor.darkGray
        }

        if let date = courseDate.date {
            self.detailView.text = CourseDateCell.dateFormatter.string(from: date)
        } else {
            self.detailView.text = "Unknown"
        }

    }
    
}
