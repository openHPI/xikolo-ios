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

    func configure(course: Course) {
        course.loadImage().onSuccess { image in
            self.backgroundImage.image = image
        }

        nameLabel.text = course.title
        teacherLabel.text = course.teachers
        dateLabel.text = course.language_translated
    }

}
