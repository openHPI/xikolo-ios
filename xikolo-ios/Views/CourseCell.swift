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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!

    func configure(course: Course) {
        course.loadImage().onSuccess { image in
            self.backgroundImage.image = image
        }

        nameLabel.text = course.title
        teacherLabel.text = course.teachers
        dateLabel.text = course.language_translated

        switch course.status {
        case "active"?:
            statusView.hidden = false
            statusLabel.text = NSLocalizedString("running", comment: "course-status")
            statusView.backgroundColor = UIColor.init(red: 140/255, green: 179/255, blue: 13/255, alpha: 1.0)
        case "self-paced"?:
            statusView.hidden = false
            statusLabel.text = NSLocalizedString("self-paced", comment: "course-status")
            statusView.backgroundColor = UIColor.init(red: 245/255, green: 167/255, blue: 4/255, alpha: 1.0)
        case "announced"?:
            statusView.hidden = false
            statusLabel.text = NSLocalizedString("upcoming", comment: "course-status")
            statusView.backgroundColor = UIColor.init(red: 20/255, green: 136/255, blue: 255/255, alpha: 1.0)
        default:
            statusView.hidden = true
        }
    }

}
