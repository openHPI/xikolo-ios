//
//  CourseDetailViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 25.02.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit

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
        languageView.text = course.language_translated
        teacherView.text = course.teachers

        if let startDate = course.start_at, let endDate = course.end_at {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateView.text = dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
        }

        course.loadImage().onSuccess { image in
            self.imageView.image = image
        }

        if let description = course.abstract {//TODO: change back to course_description when API works
            let markDown = try? MarkdownHelper.parse(description) // TODO: Error handling
            descriptionView.attributedText = markDown
        }
    }

}
