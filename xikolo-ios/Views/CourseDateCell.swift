//
//  CourseDateCell.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 17.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import UIKit

class CourseDateCell : UITableViewCell {

    @IBOutlet var titleView: UILabel!
    @IBOutlet var detailView: UILabel!

    func configure(courseDate: CourseDate) {
        titleView.text = courseDate.title

        if let date = courseDate.date {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .NoStyle

            detailView.text = dateFormatter.stringFromDate(date)
        } else {
            detailView.text = courseDate.type
        }

    }
    
}
