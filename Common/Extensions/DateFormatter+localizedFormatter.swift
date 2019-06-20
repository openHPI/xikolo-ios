//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension DateFormatter {

    public static func localizedFormatter(locale: Locale = Brand.default.locale,
                                          calendar: Calendar = Calendar.autoupdatingCurrent,
                                          timeZone: TimeZone = TimeZone.autoupdatingCurrent) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        dateFormatter.timeZone = timeZone
        return dateFormatter
    }

}

extension DateIntervalFormatter {

    public static func localizedFormatter(locale: Locale = Brand.default.locale,
                                          calendar: Calendar = Calendar.autoupdatingCurrent,
                                          timeZone: TimeZone = TimeZone.autoupdatingCurrent) -> DateIntervalFormatter {
        let dateIntervalFormatter = DateIntervalFormatter()
        dateIntervalFormatter.locale = locale
        dateIntervalFormatter.calendar = calendar
        dateIntervalFormatter.timeZone = timeZone
        return dateIntervalFormatter
    }

}
