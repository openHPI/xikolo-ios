//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import SwiftUI
import WidgetKit

struct ContinueLearningWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> ContinueLearningWidgetEntry {
        ContinueLearningWidgetEntry(course: nil) // TODO use example course
    }

    func getSnapshot(in context: Context, completion: @escaping (ContinueLearningWidgetEntry) -> ()) {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let currentCourses = context.fetchMultiple(CourseHelper.FetchRequest.enrolledCurrentCoursesRequest)
            let entry = ContinueLearningWidgetEntry(course: currentCourses.value?.count)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            var entries: [ContinueLearningWidgetEntry] = []
            let currentCourses = context.fetchMultiple(CourseHelper.FetchRequest.enrolledCurrentCoursesRequest)
            let entry = ContinueLearningWidgetEntry(course: currentCourses.value?.count)
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
    }
}

struct ContinueLearningWidgetEntry: TimelineEntry {
    let date: Date = Date()
    var course: Int?
}

struct ContinueLearningWidgetEntryView : View {
    var entry: ContinueLearningWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            ZStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text("\(entry.course ?? -1)")
                        .lineLimit(2)
                    Text("Item title")
                        .font(.system(.footnote))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        default:
            ZStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Very long long a course title")
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Item title")
                            .font(.system(.footnote))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: .infinity)

                    VStack(alignment: .leading) {
                        Text("Very long long a course title")
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Item title")
                            .font(.system(.footnote))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding()
            }
        }
    }
}

struct ContinueLearningWidget: Widget {
    let kind = "continue-learning"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ContinueLearningWidgetProvider()) { entry in
            ContinueLearningWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Continue Learning")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ContinueLearningWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContinueLearningWidgetEntryView(entry: ContinueLearningWidgetEntry(course: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            ContinueLearningWidgetEntryView(entry: ContinueLearningWidgetEntry(course: nil))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
