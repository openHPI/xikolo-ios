//
//  CourseCell.swift
//  xikolo-tvos
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class CourseCell : UICollectionViewCell {

    @IBOutlet weak var backgroundImage: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    func configure(course: Course) {
        course.loadImage().onSuccess { image in
            self.backgroundImage.image = image
        }
        nameLabel.text = course.name
    }

}
