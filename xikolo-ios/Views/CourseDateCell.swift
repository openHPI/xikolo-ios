//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

class CourseDateCell: UITableViewCell {

    @IBOutlet private var courseLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.localizedFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.courseLabel.textColor = Brand.Color.secondary
    }

    func configure(_ courseDate: CourseDate) {
        self.dateLabel.text = self.dateText(for: courseDate)
        self.courseLabel.text = courseDate.course?.title
        self.titleLabel.text = self.title(for: courseDate)
    }

    private func title(for courseDate: CourseDate) -> String {
        let title = courseDate.title ?? "Unknown"
        switch courseDate.type {
        case "course_start"?:
            return NSLocalizedString("course-date-cell.course-start.title",
                                     comment: "title for course start in a course date cell")
        case "section_start"?:
            let format = NSLocalizedString("course-date-cell.section-start.title.%@ starts",
                                           comment: "format for section start in course date cell")
            return String.localizedStringWithFormat(format, title)
        case "item_submission_deadline"?:
            let format = NSLocalizedString("course-date-cell.item-submission.title.submission for %@ ends",
                                           comment: "format for item submission in course date cell")
            return String.localizedStringWithFormat(format, title)
        default:
            return title
        }
    }

    private func dateText(for courseDate: CourseDate) -> String {
        guard let date = courseDate.date else {
            return "Unknown"
        }

        var dateText = CourseDateCell.dateFormatter.string(from: date)
        if let timeZoneAbbreviation = TimeZone.current.abbreviation() {
            dateText += " (\(timeZoneAbbreviation))"
        }

        return dateText
    }

}
