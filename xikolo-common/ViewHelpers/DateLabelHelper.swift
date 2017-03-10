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
                return format(date: start) + " - " + format(date: end)
            } else {
                if start.timeIntervalSinceNow > 0 {
                    // startdate in the future
                    return NSLocalizedString("Beginning", comment: "") + " " + format(date: start)
                } else {
                    // startdate in the past
                    #if OPENWHO
                        return NSLocalizedString("Self-paced", comment: "")
                    #else
                        return NSLocalizedString("Since", comment: "") + " " + format(date: start)
                    #endif
                }
            }
        } else {
            // neither start nor enddate
            return NSLocalizedString("Coming soon", comment: "")
        }
    }

    private class func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }

}
