//
//  CourseCell.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 16.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import Hero
import SDWebImage

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
        backgroundImage.sd_setShowActivityIndicatorView(true)
        backgroundImage.sd_setIndicatorStyle(.gray)
        backgroundImage.sd_setImage(with: course.image_url)

        nameLabel.text = course.title
        nameLabel.heroID = "course_title_" + course.id
        teacherLabel.text = course.teachers
        teacherLabel.textColor = Brand.TintColorSecond
        teacherLabel.heroID = "course_teacher_" + course.id
        languageLabel.text = course.language_translated
        languageLabel.heroID = "course_language_" + course.id
        languageLabel.text = course.language_translated
        backgroundImage.heroID = "course_image_" + course.id
        dateLabel.text = DateLabelHelper.labelFor(startdate: course.start_at, enddate: course.end_at)

        #if OPENWHO //view is hidden by default
        #else
        switch course.status {
        case "active"?:
            statusView.isHidden = false
            statusLabel.text = NSLocalizedString("running", comment: "course-status")
            statusView.backgroundColor = Brand.TintColorThird
        default:
            statusView.isHidden = true
        }
        #endif
    }

}
