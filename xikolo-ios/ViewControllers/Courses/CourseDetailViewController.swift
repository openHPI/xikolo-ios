//
//  CourseDetailViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 25.02.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit
import Hero

class CourseDetailViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var languageView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var teacherView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!

    var cdCourse: Course!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleView.text = cdCourse.title
        titleView.heroID = "course_title_" + cdCourse.id
        languageView.text = cdCourse.language_translated
        languageView.heroID = "course_language_" + cdCourse.id
        teacherView.text = cdCourse.teachers
        teacherView.heroID = "course_teacher_" + cdCourse.id
        imageView.heroID = "course_image_" + cdCourse.id
        
        dateView.text = DateLabelHelper.labelFor(startdate: cdCourse.start_at, enddate: cdCourse.end_at)

        cdCourse.loadImage().onSuccess { image in
            self.imageView.image = image
        }

        if let description = cdCourse.abstract {//TODO: change back to course_description when API works
            let markDown = try? MarkdownHelper.parse(description) // TODO: Error handling
            descriptionView.attributedText = markDown
        }
    }

}
