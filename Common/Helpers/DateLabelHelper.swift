//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public enum DateLabelHelper {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.localizedFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    private static let dateIntervalFormatter: DateIntervalFormatter = {
        let dateIntervalFormatter = DateIntervalFormatter.localizedFormatter()
        dateIntervalFormatter.dateStyle = .long
        dateIntervalFormatter.timeStyle = .none
        return dateIntervalFormatter
    }()

    public static func labelFor(startDate: Date?, endDate: Date?) -> String {
        if endDate?.inPast ?? false {
            return CommonLocalizedString("course-date-formatting.self-paced", comment: "Self-paced course")
        }

        if let startDate = startDate, startDate.inPast, endDate == nil {
            switch Brand.default.courseDateLabelStyle {
            case .normal:
                let format = CommonLocalizedString("course-date-formatting.started.since %@", comment: "course start at specfic date in the past")
                return String.localizedStringWithFormat(format, self.dateFormatter.string(from: startDate))
            case .who:
                return CommonLocalizedString("course-date-formatting.self-paced", comment: "Self-paced course")
            }
        }

        if let startDate = startDate, startDate.inFuture, endDate == nil {
            switch Brand.default.courseDateLabelStyle {
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
