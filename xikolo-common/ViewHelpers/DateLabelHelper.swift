//
//  DateLabelHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 09.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

class DateLabelHelper {

    class func labelFor(startdate: Date?, enddate: Date?) -> String {
        if let start = startdate {
            if let end = enddate {
                // start & enddate
                return self.format(date: start) + " - " + format(date: end)
            } else {
                if start.timeIntervalSinceNow > 0 {
                    // startdate in the future
                    let format = NSLocalizedString("course-date-formatting.not-started.beginning %@",
                                                   comment: "course start at specific date in the future")
                    return String.localizedStringWithFormat(format, self.format(date: start))
                } else {
                    // startdate in the past
                    #if OPENWHO
                        let format = NSLocalizedString("course-date-formatting.started.since %@",
                                                       comment: "course start at specfic date in the past")
                        return String.localizedStringWithFormat(format, self.format(date: start))
                    #else
                        return NSLocalizedString("course-date-formatting.self-paced", comment: "Self-paced course")
                    #endif
                }
            }
        } else {
            // neither start nor enddate
            return NSLocalizedString("course-date-formatting.not-started.coming soon",
                                     comment: "course start at unknown date")
        }
    }

    private class func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }

}
