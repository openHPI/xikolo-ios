//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct NextCourseDateWidgetEntryView : View {
    var entry: CourseDateOverviewWidgetProvider.Entry

    var body: some View {
        if !entry.userIsLoggedIn {
            NotLoggedInView()
        } else if let courseDate = entry.nextCourseDate {
            CourseDateView(courseDate: courseDate)
                .padding()
        } else {
            EmptyCourseDatesView()
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
