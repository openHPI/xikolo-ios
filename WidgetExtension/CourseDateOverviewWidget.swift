//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit


import Common

struct CourseDateOverviewView: View {

    var courseDateOverview: CourseDateOverviewViewModel

    var body: some View {
        VStack {
            Text("Course Date Overview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            Spacer()
            HStack {
                Text("Today")
                Spacer()
                Text("\(courseDateOverview.todayCount)")
                    .font(.callout)
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 2)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            Spacer()
            HStack {
                Text("Next 7 Days")
                Spacer()
                Text("\(courseDateOverview.nextCount)")
                    .font(.callout)
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 2)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            Spacer()
            HStack {
                Text("All")
                Spacer()
                Text("\(courseDateOverview.allCount)")
                    .font(.callout)
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 2)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }

}


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

struct CourseDateOverviewWidget_Previews: PreviewProvider {

    static var exampleCourseDateOverview: CourseDateOverviewViewModel {
        CourseDateOverviewViewModel(todayCount: 1, nextCount: 2, allCount: 4)
    }

    static var previews: some View {
        CourseDateOverviewWidgetEntryView(entry: CourseDateOverviewWidgetEntry(courseDateOverview: exampleCourseDateOverview, userIsLoggedIn: true))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
    }

}
