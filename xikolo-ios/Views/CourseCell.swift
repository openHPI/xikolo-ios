//
//  CourseCell.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 16.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
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
        backgroundImage.sd_setImage(with: course.imageURL)

        nameLabel.text = course.title
        teacherLabel.text = course.teachers
        teacherLabel.textColor = Brand.TintColorSecond
        languageLabel.text = course.language_translated
        languageLabel.text = course.language_translated
        dateLabel.text = DateLabelHelper.labelFor(startdate: course.startsAt, enddate: course.endsAt)

        #if OPENWHO //view is hidden by default
        #else
        switch course.status {
        case "active"?:
            statusView.isHidden = false
            statusLabel.text = NSLocalizedString("course-cell.status.running", comment: "status 'running' of a course")
            statusView.backgroundColor = Brand.TintColorThird
        default:
            statusView.isHidden = true
        }
        #endif
    }

}
