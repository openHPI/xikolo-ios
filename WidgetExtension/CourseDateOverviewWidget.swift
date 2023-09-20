//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CourseDateOverviewWidgetEntryView: View {
    var entry: CourseDateOverviewWidgetProvider.Entry

    var body: some View {
        Group {
            if !entry.userIsLoggedIn {
                EmptyStateView.notLoggedIn
            } else if let courseDate = entry.nextCourseDate {
                HStack {
                    CourseDateStatisticsView(courseDateStatistics: entry.courseDateStatistics)
                    Divider()
                        .padding(.horizontal, 4) // todo change to vertical
                    CourseDateView(courseDate: courseDate)
                        .widgetURL(courseDate.url)
                }
                .backport.widgetPadding()
            } else {
                EmptyStateView.noCourseDates
            }
        }
        .backport.widgetBackground()
    }
}

struct CourseDateOverviewWidget: Widget {

    let kind = "course-date-overview"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CourseDateOverviewWidgetProvider()) { entry in
            CourseDateOverviewWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("widget-metadata.course-date-overview.title")
        .description("widget-metadata.course-date-overview.description")
        .supportedFamilies([.systemMedium])
    }

}
