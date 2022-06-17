//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public enum CoursePeriodFormatter {

    private static let dateFormatter = DateFormatter.localizedFormatter(dateStyle: .medium, timeStyle: .none)
    private static let dateIntervalFormatter = DateIntervalFormatter.localizedFormatter(dateStyle: .medium, timeStyle: .none)

    public static func string(from course: Course) -> String {
        return self.string(fromStartDate: course.startsAt, endDate: course.endsAt)
    }

    static func string(fromStartDate startDate: Date?, endDate: Date?, withStyle style: CourseDateLabelStyle = Brand.default.courseDateLabelStyle) -> String {
        if let endDate = endDate, endDate.inPast {
            let format = CommonLocalizedString("course-date-formatting.self-paced since %@", comment: "Self-paced course (since end date)")
            let formattedDate = self.dateFormatter.string(from: endDate)
            let nonBreakingFormattedDate = formattedDate.replacingOccurrences(of: " ", with: "\u{00a0}")
            return String.localizedStringWithFormat(format, nonBreakingFormattedDate)
        }

        if let startDate = startDate, startDate.inPast, endDate == nil {
            switch style {
            case .normal:
                let format = CommonLocalizedString("course-date-formatting.started.since %@", comment: "course start at specific date in the past")
                let formattedDate = self.dateFormatter.string(from: startDate)
                let nonBreakingFormattedDate = formattedDate.replacingOccurrences(of: " ", with: "\u{00a0}")
                return String.localizedStringWithFormat(format, nonBreakingFormattedDate)
            case .who:
                return CommonLocalizedString("course-date-formatting.self-paced", comment: "Self-paced course")
            }
        }

        if let startDate = startDate, startDate.inFuture, endDate == nil {
            switch style {
            case .normal:
                let format = CommonLocalizedString("course-date-formatting.not-started.beginning %@", comment: "course start at specific date in the future")
                let formattedDate = self.dateFormatter.string(from: startDate)
                let nonBreakingFormattedDate = formattedDate.replacingOccurrences(of: " ", with: "\u{00a0}")
                return String.localizedStringWithFormat(format, nonBreakingFormattedDate)
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
