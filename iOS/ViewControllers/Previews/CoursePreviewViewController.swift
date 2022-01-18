//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CoursePreviewViewController: UIViewController {

    @IBOutlet private weak var courseImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var teacherLabel: UILabel!
    @IBOutlet private weak var dateIconView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var languageIconView: UIImageView!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!

    let course: Course
    let listConfiguration: CourseListConfiguration

    init?(coder: NSCoder, course: Course, listConfiguration: CourseListConfiguration) {
        self.course = course
        self.listConfiguration = listConfiguration
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with a course.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let accentColor = self.listConfiguration.colorWithFallback(to: Brand.default.colors.secondary)
        self.courseImageView.backgroundColor = accentColor
        self.teacherLabel.textColor = accentColor

        self.courseImageView.sd_imageTransition = .fade
        self.courseImageView.sd_setImage(with: self.course.imageURL)

        self.titleLabel.text = self.course.title
        self.teacherLabel.text = self.course.teachers

        self.dateLabel.text = CoursePeriodFormatter.string(from: self.course)
        self.languageLabel.text = self.course.language.flatMap(LanguageLocalizer.nativeDisplayName(for:))

        if #available(iOS 13, *) {
            let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .callout)
            self.languageIconView.image = UIImage(systemName: "globe", withConfiguration: symbolConfiguration)
            self.languageIconView.tintColor = ColorCompatibility.secondaryLabel
            self.dateIconView.image = UIImage(systemName: "calendar", withConfiguration: symbolConfiguration)
            self.dateIconView.tintColor = ColorCompatibility.secondaryLabel
        } else {
            self.languageIconView.isHidden = true
            self.dateIconView.isHidden = true
        }

        self.descriptionView.textContainerInset = .zero
        self.descriptionView.textContainer.lineFragmentPadding = 0
        self.descriptionView.attributedText = self.course.abstract.map(MarkdownHelper.attributedString(for:))
    }

}
