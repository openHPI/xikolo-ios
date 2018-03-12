//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension DateFormatter {

    static func localizedFormatter(locale: Locale = Locale.autoupdatingCurrent,
                                   calendar: Calendar = Calendar.autoupdatingCurrent,
                                   timeZone: TimeZone = TimeZone.autoupdatingCurrent) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        dateFormatter.timeZone = timeZone
        return dateFormatter
    }

}
