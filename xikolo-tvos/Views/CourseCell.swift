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

    func configure(_ course: Course) {
        backgroundImage.sd_setImage(with: course.image_url)
        nameLabel.text = course.title
    }

}
