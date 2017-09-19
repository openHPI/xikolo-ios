//
//  DateLabelHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 09.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

class DateLabelHelper {

    fileprivate static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    class func labelFor(startdate: Date?, enddate: Date?) -> String {
        if let start = startdate {
            if let end = enddate {
                // start & enddate
                return self.format(date: start) + " - " + format(date: end)
            } else {
                if start.timeIntervalSinceNow > 0 {
                    // startdate in the future
                    let format = NSLocalizedString("course-date-formatting.not-started.beginning %@",
                                                   tableName: "Common",
                                                   comment: "course start at specific date in the future")
                    return String.localizedStringWithFormat(format, self.format(date: start))
                } else {
                    // startdate in the past
                    #if OPENWHO
                        let format = NSLocalizedString("course-date-formatting.started.since %@",
                                                       tableName: "Common",
                                                       comment: "course start at specfic date in the past")
                        return String.localizedStringWithFormat(format, self.format(date: start))
                    #else
                        return NSLocalizedString("course-date-formatting.self-paced",
                                                 tableName: "Common",
                                                 comment: "Self-paced course")
                    #endif
                }
            }
        } else {
            // neither start nor enddate
            return NSLocalizedString("course-date-formatting.not-started.coming soon",
                                     tableName: "Common",
                                     comment: "course start at unknown date")
        }
    }

    private class func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }

}
