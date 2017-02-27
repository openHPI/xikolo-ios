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

    func configure(_ course: Course) {
        backgroundImage.image = nil
        backgroundImage.backgroundColor = UIColor.gray
        course.loadImage().onSuccess { image in
            self.backgroundImage.image = image
        }

        nameLabel.text = course.title
        teacherLabel.text = course.teachers
        languageLabel.text = course.language_translated

        if let startDate = course.start_at, let endDate = course.end_at {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateLabel.text = dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
        }

        switch course.status {
        case "active"?:
            statusView.isHidden = false
            statusLabel.text = NSLocalizedString("running", comment: "course-status")
            statusView.backgroundColor = Brand.FlagRunningColor
        case "self-paced"?:
            statusView.isHidden = false
            statusLabel.text = NSLocalizedString("self-paced", comment: "course-status")
            statusView.backgroundColor = Brand.FlagSelfpacedColor
        case "announced"?:
            statusView.isHidden = false
            statusLabel.text = NSLocalizedString("upcoming", comment: "course-status")
            statusView.backgroundColor = Brand.FlagUpcomingColor
        default:
            statusView.isHidden = true
        }
    }

}
