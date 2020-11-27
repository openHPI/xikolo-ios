//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import WidgetKit
import SwiftUI

struct ContinueLearningWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> ContinueLearningWidgetEntry {
        ContinueLearningWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ContinueLearningWidgetEntry) -> ()) {
        let entry = ContinueLearningWidgetEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ContinueLearningWidgetEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ContinueLearningWidgetEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ContinueLearningWidgetEntry: TimelineEntry {
    let date: Date
}

struct ContinueLearningWidgetEntryView : View {
    var entry: ContinueLearningWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            ZStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text("Very long longacourse")
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
    }
}

struct ContinueLearningWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContinueLearningWidgetEntryView(entry: ContinueLearningWidgetEntry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            ContinueLearningWidgetEntryView(entry: ContinueLearningWidgetEntry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
