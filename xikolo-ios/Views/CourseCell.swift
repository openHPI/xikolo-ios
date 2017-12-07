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

    @IBOutlet weak var courseImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.courseImage.layer.cornerRadius = 4.0
        self.courseImage.layer.masksToBounds = true

        self.statusView.layer.cornerRadius = 4.0
        self.statusView.layer.masksToBounds = true

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.gradientView.frame.size.width, height: self.gradientView.frame.size.height)
        self.gradientView.layer.insertSublayer(gradient, at: 0)
        self.gradientView.layer.cornerRadius = 4.0
        self.gradientView.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientView.layer.sublayers?.first?.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.gradientView.frame.size.height)
    }

    func configure(_ course: Course) {
        courseImage.image = nil
        courseImage.backgroundColor = Brand.TintColor.withAlphaComponent(0.2)
        courseImage.sd_setShowActivityIndicatorView(true)
        courseImage.sd_setIndicatorStyle(.gray)
        courseImage.sd_setImage(with: course.imageURL)

        titleLabel.text = course.title
        teacherLabel.text = course.teachers
        teacherLabel.textColor = Brand.TintColorSecond
        languageLabel.text = course.language_translated
        languageLabel.text = course.language_translated
        dateLabel.text = DateLabelHelper.labelFor(startdate: course.startsAt, enddate: course.endsAt)

        self.statusView.isHidden = true

        if course.hasEnrollment {
            self.statusView.isHidden = false
            self.statusLabel.text = NSLocalizedString("course-cell.status.enrolled", comment: "status 'enrolled' of a course")
            self.statusView.backgroundColor = Brand.TintColorSecond
        }
//        #if OPENWHO //view is hidden by default
//        #else
//        switch course.status {
//        case "active"?:
//            statusView.isHidden = false
//            statusLabel.text = NSLocalizedString("course-cell.status.running", comment: "status 'running' of a course")
//            statusView.backgroundColor = Brand.TintColorThird
//        default:
//            break
////            statusView.isHidden = true
//        }
//        #endif
    }

}
