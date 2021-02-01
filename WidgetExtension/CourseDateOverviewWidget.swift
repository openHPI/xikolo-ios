//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CourseDateOverviewWidgetEntryView : View {
    var entry: CourseDateOverviewWidgetProvider.Entry

    var body: some View {
        if !entry.userIsLoggedIn {
            NotLoggedInView()
                .padding()
        } else if let courseDateOverview = entry.courseDateOverview {
            CourseDateOverviewView(courseDateOverview: courseDateOverview)
                .padding()
        } else {
            EmptyContentView()
                .padding()
        }
    }
}

struct CourseDateOverviewWidget: Widget {

    let kind = "course-date-overview"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CourseDateOverviewWidgetProvider()) { entry in
            CourseDateOverviewWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Course Date Overview")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }

}
