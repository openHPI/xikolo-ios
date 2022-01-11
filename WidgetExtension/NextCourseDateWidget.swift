//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct NextCourseDateWidgetEntryView: View {
    var entry: CourseDateOverviewWidgetProvider.Entry

    var body: some View {
        if !entry.userIsLoggedIn {
            EmptyStateView.notLoggedIn
        } else if let courseDate = entry.nextCourseDate {
            CourseDateView(courseDate: courseDate)
                .padding()
        } else {
            EmptyStateView.noCourseDates
        }
    }
}

struct NextCourseDateWidget: Widget {

    let kind = "course-date-next"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CourseDateOverviewWidgetProvider()) { entry in
            NextCourseDateWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("widget-metadata.course-date-next.title")
        .description("widget-metadata.course-date-next.description")
        .supportedFamilies([.systemSmall])
    }

}
