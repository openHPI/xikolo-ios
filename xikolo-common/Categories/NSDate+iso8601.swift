//
//  NSDate+iso8601.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

private struct DateFormatters {

    static let dateFromISOStringFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

}

extension NSDate {

    class func dateFromISOString(string: String?) -> NSDate? {
        if string == nil {
            return nil
        }
        return DateFormatters.dateFromISOStringFormatter.dateFromString(string!)
    }

}
