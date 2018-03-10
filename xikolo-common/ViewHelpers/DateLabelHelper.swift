//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

class DateLabelHelper {

    fileprivate static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.localizedFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    class func labelFor(startDate: Date?, endDate: Date?) -> String {
        if endDate?.inPast ?? false {
            return NSLocalizedString("course-date-formatting.self-paced", tableName: "Common", comment: "Self-paced course")
        }

        if let startDate = startDate, startDate.inPast, endDate == nil {
            #if OPENWHO
                return NSLocalizedString("course-date-formatting.self-paced", tableName: "Common", comment: "Self-paced course")
            #else
                let format = NSLocalizedString("course-date-formatting.started.since %@",
                                               tableName: "Common",
                                               comment: "course start at specfic date in the past")
                return String.localizedStringWithFormat(format, self.format(date: startDate))
            #endif
        }

        if let startDate = startDate, startDate.inFuture, endDate == nil {
            #if OPENWHO
                return NSLocalizedString("course-date-formatting.not-started.coming soon",
                                         tableName: "Common",
                                         comment: "course start at unknown date")
            #else
                let format = NSLocalizedString("course-date-formatting.not-started.beginning %@",
                                               tableName: "Common",
                                               comment: "course start at specific date in the future")
                return String.localizedStringWithFormat(format, self.format(date: startDate))
            #endif
        }

        if let startDate = startDate, let endDate = endDate {
            return self.format(date: startDate) + " - " + format(date: endDate)
        }

        return NSLocalizedString("course-date-formatting.not-started.coming soon",
                                 tableName: "Common",
                                 comment: "course start at unknown date")
    }

    private class func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }

}
