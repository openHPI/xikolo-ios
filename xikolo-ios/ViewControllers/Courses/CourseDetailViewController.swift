//
//  CourseDetailViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 25.02.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit
import Hero
import SDWebImage

class CourseDetailViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var languageView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var teacherView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!

    var course: Course!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleView.text = course.title
        titleView.heroID = "course_title_" + course.id
        languageView.text = course.language_translated
        languageView.heroID = "course_language_" + course.id
        teacherView.text = course.teachers
        teacherView.textColor = Brand.TintColorSecond
        teacherView.heroID = "course_teacher_" + course.id
        imageView.heroID = "course_image_" + course.id
        
        dateView.text = DateLabelHelper.labelFor(startdate: course.start_at, enddate: course.end_at)
        imageView.sd_setImage(with: course.image_url)

        if let description = course.abstract {//TODO: change back to course_description when API works
            let markDown = try? MarkdownHelper.parse(description) // TODO: Error handling
            descriptionView.attributedText = markDown
        }
    }

}
