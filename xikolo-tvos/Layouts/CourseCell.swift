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
        if let image_url = course.image_url {
            ImageHelper.loadImageFromURL(image_url, toImageView: backgroundImage)
        }
        nameLabel.text = course.name
    }

}
