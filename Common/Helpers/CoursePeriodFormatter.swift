//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public enum CoursePeriodFormatter {

    private static let dateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .none)
    private static let dateIntervalFormatter = DateIntervalFormatter.localizedFormatter(dateStyle: .long, timeStyle: .none)

    public static func string(from course: Course) -> String {
        return self.string(fromStartDate: course.startsAt, endDate: course.endsAt)
    }

    static func string(fromStartDate startDate: Date?, endDate: Date?, withStyle style: CourseDateLabelStyle = Brand.default.courseDateLabelStyle) -> String {
        if endDate?.inPast ?? false {
            return CommonLocalizedString("course-date-formatting.self-paced", comment: "Self-paced course")
        }

        if let startDate = startDate, startDate.inPast, endDate == nil {
            switch style {
            case .normal:
                let format = CommonLocalizedString("course-date-formatting.started.since %@", comment: "course start at specfic date in the past")
                return String.localizedStringWithFormat(format, self.dateFormatter.string(from: startDate))
            case .who:
                return CommonLocalizedString("course-date-formatting.self-paced", comment: "Self-paced course")
            }
        }

        if let startDate = startDate, startDate.inFuture, endDate == nil {
            switch style {
            case .normal:
                let format = CommonLocalizedString("course-date-formatting.not-started.beginning %@", comment: "course start at specific date in the future")
                return String.localizedStringWithFormat(format, self.dateFormatter.string(from: startDate))
            case .who:
                return CommonLocalizedString("course-date-formatting.not-started.coming soon", comment: "course start at unknown date")
            }
        }

        if let startDate = startDate, let endDate = endDate {
            return self.dateIntervalFormatter.string(from: startDate, to: endDate)
        }

        return CommonLocalizedString("course-date-formatting.not-started.coming soon", comment: "course start at unknown date")
    }

}
