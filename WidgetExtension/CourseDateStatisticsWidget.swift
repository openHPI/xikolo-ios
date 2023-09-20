//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CourseDateStatisticsWidgetEntryView: View {
    var entry: CourseDateOverviewWidgetProvider.Entry

    var body: some View {
        Group {
            if !entry.userIsLoggedIn {
                EmptyStateView.notLoggedIn
            } else if entry.nextCourseDate != nil {
                CourseDateStatisticsView(courseDateStatistics: entry.courseDateStatistics)
                    .backport.widgetPadding()
            } else {
                EmptyStateView.noCourseDates
            }
        }
        .backport.widgetBackground()
    }
}

struct CourseDateStatisticsWidget: Widget {

    let kind = "course-date-statistics"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CourseDateOverviewWidgetProvider()) { entry in
            CourseDateStatisticsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("widget-metadata.course-date-statistics.title")
        .description("widget-metadata.course-date-statistics.description")
        .supportedFamilies([.systemSmall])
    }

}
