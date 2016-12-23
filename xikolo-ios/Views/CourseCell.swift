//
//  CourseCell.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 16.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit

class CourseCell : UICollectionViewCell {

    @IBOutlet weak var backgroundImage: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!

    func configure(course: Course) {
        course.loadImage().onSuccess { image in
            self.backgroundImage.image = image
        }

        nameLabel.text = course.title
        teacherLabel.text = course.teachers
        languageLabel.text = course.language_translated

        if let startDate = course.start_at, endDate = course.end_at {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .NoStyle
            dateLabel.text = dateFormatter.stringFromDate(startDate) + " - " + dateFormatter.stringFromDate(endDate)
        }

        switch course.status {
        case "active"?:
            statusView.hidden = false
            statusLabel.text = NSLocalizedString("running", comment: "course-status")
            statusView.backgroundColor = Brand.FlagRunningColor
        case "self-paced"?:
            statusView.hidden = false
            statusLabel.text = NSLocalizedString("self-paced", comment: "course-status")
            statusView.backgroundColor = Brand.FlagSelfpacedColor
        case "announced"?:
            statusView.hidden = false
            statusLabel.text = NSLocalizedString("upcoming", comment: "course-status")
            statusView.backgroundColor = Brand.FlagUpcomingColor
        default:
            statusView.hidden = true
        }
    }

}
