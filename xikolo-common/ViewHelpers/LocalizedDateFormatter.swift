//
//  LocalizedDateFormatter.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 19.09.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

class LocalizedDateFormatterFactory {
    class func newDateFormatter(with locale: Locale = Locale.current, and calendar: Calendar = Calendar.current, and timeZone: TimeZone = TimeZone.current) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        dateFormatter.timeZone = timeZone
        return dateFormatter
    }

}
