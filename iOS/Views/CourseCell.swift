//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SDWebImage
import UIKit

class CourseCell: UICollectionViewCell {

    enum Configuration {
        case courseList
        case courseActivity
    }

    @IBOutlet private weak var courseImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var teacherLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isAccessibilityElement = true

        self.courseImage.layer.cornerRadius = 4.0
        self.courseImage.layer.masksToBounds = true
        self.courseImage.layer.borderColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.courseImage.layer.borderWidth = 0.5
        self.courseImage.backgroundColor = Brand.default.colors.secondary

        self.statusView.layer.cornerRadius = 4.0
        self.statusView.layer.masksToBounds = true
        self.statusView.backgroundColor = Brand.default.colors.secondary

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.gradientView.frame.size.width, height: self.gradientView.frame.size.height)
        self.gradientView.layer.insertSublayer(gradient, at: 0)
        self.gradientView.layer.cornerRadius = 4.0
        self.gradientView.layer.masksToBounds = true

        self.teacherLabel.textColor = Brand.default.colors.secondary
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientView.layer.sublayers?.first?.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.gradientView.frame.size.height)
    }

    func configure(_ course: Course, forConfiguration configuration: Configuration) {
        self.courseImage.image = nil
        self.gradientView.isHidden = true
        self.courseImage.sd_setImage(with: course.imageURL, placeholderImage: nil) { image, _, _, _ in
            self.gradientView.isHidden = (image == nil)
        }

        self.titleLabel.text = course.title
        self.teacherLabel.text = course.teachers
        self.languageLabel.text = course.localizedLanguage
        self.dateLabel.text = DateLabelHelper.labelFor(startDate: course.startsAt, endDate: course.endsAt)

        self.statusView.isHidden = true
        switch configuration {
        case .courseList:
            if let enrollment = course.enrollment {
                self.statusView.isHidden = false
                if enrollment.completed {
                    self.statusLabel.text = NSLocalizedString("course-cell.status.completed", comment: "status 'completed' of a course")
                } else {
                    self.statusLabel.text = NSLocalizedString("course-cell.status.enrolled", comment: "status 'enrolled' of a course")
                }
            }
        case .courseActivity:
            if let enrollment = course.enrollment, enrollment.completed {
                self.statusView.isHidden = false
                self.statusLabel.text = NSLocalizedString("course-cell.status.completed", comment: "status 'completed' of a course")
            } else if course.status == "announced" {
                self.statusView.isHidden = false
                self.statusLabel.text = NSLocalizedString("course-cell.status.upcoming", comment: "status 'upcoming' of a course")
            }
        }
    }

}
