//
//  CourseSectionCell.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class CourseSectionCell : UITableViewCell {

    @IBOutlet weak var titleView: UILabel!

    func configure(section: CourseSection) {
        titleView.text = section.title
    }

}