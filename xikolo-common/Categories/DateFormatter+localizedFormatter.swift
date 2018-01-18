//
//  LocalizedDateFormatter.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 19.09.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static func localizedFormatter(locale: Locale = Locale.autoupdatingCurrent, calendar: Calendar = Calendar.autoupdatingCurrent, timeZone: TimeZone = TimeZone.autoupdatingCurrent) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        dateFormatter.timeZone = timeZone
        return dateFormatter
    }

}
