//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CourseDateStatisticsWidgetEntryView : View {
    var entry: CourseDateOverviewWidgetProvider.Entry

    var body: some View {
        if !entry.userIsLoggedIn {
            NotLoggedInView()
                .padding()
        } else if entry.nextCourseDate != nil {
            CourseDateStatisticsView(courseDateStatistics: entry.courseDateStatistics)
                .padding()
        } else {
            EmptyContentView()
                .padding()
        }
    }
}

struct CourseDateStatisticsWidget: Widget {

    let kind = "course-date-statistics"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CourseDateOverviewWidgetProvider()) { entry in
            CourseDateStatisticsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Course Date Overview")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }

}
