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
        let course = CourseViewModel(title: "This is an interesting course", itemTitle: "Continue learning")
        return ContinueLearningWidgetEntry(course1: course, course2: course)
    }

    func getSnapshot(in context: Context, completion: @escaping (ContinueLearningWidgetEntry) -> ()) {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let currentCourses = context.fetchMultiple(CourseHelper.FetchRequest.enrolledCurrentCoursesRequest).value ?? []

            let entry = ContinueLearningWidgetEntry(
                course1: currentCourses.first.map(CourseViewModel.init(course:)),
                course2: currentCourses.count > 1 ? CourseViewModel(course: currentCourses[1]) : nil
            )

            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            var entries: [ContinueLearningWidgetEntry] = []
            let currentCourses = context.fetchMultiple(CourseHelper.FetchRequest.enrolledCurrentCoursesRequest).value ?? []

            let entry = ContinueLearningWidgetEntry(
                course1: currentCourses.first.map(CourseViewModel.init(course:)),
                course2: currentCourses.count > 1 ? CourseViewModel(course: currentCourses[1]) : nil
            )

            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct CourseViewModel {
    var title: String
    var itemTitle: String?
    var image: UIImage?
//    var url: URL?
}

extension CourseViewModel {
    init(course: Course) {
        self.title = course.title ?? "empty"
        self.itemTitle = "Continue learning"

        self.image = try? course.imageURL.map {
            try Data(contentsOf: $0)
        }.flatMap {
            UIImage(data: $0)
        }
    }
}

struct ContinueLearningWidgetEntry: TimelineEntry {
    let date: Date = Date()
    var course1: CourseViewModel?
    var course2: CourseViewModel?
}

struct EmptyContentView: View {

    var body: some View {
        ZStack {
            VStack {
                Text("Enroll into more courses")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primary)
                Text("To see your latest accessed course here")
                    .multilineTextAlignment(.center)
                    .font(.system(.footnote))
                    .foregroundColor(Color.secondary)
            }
            .padding()
        }
        .background(Color.orange)
    }

}

struct ContinueLearningWidgetEntryView : View {
    var entry: ContinueLearningWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        if let course1 = entry.course1 {
            switch family {
            case .systemSmall:
                smallContentView(for: course1)
            default:
                mediumContentView(for: course1, and: entry.course2)
            }
        } else {
            EmptyContentView()
        }
    }

    var gradient: Gradient {
        Gradient(stops:
                    [Gradient.Stop(color: .clear, location: 0.25),
                     Gradient.Stop(color: Color(UIColor.systemBackground),
                                   location: 0.65)])
    }

    @ViewBuilder
    func smallContentView(for course: CourseViewModel) -> some View {
        ZStack {
            if let image = course.image {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: 150)
                        .background(Color.green)
                    Spacer()
                }
            }

            VStack {
                Spacer()
                LinearGradient(gradient: gradient,
                               startPoint: .top,
                               endPoint: .bottom)
                    .frame(maxHeight: .infinity)
            }
            VStack(alignment: .leading) {
                Spacer()
                Text(course.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(Color.primary)
                if let itemTitle = course.itemTitle {
                    Text(itemTitle)
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }

    @ViewBuilder
    func mediumContentView(for course1: CourseViewModel, and course2: CourseViewModel?) -> some View {
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
        .background(Color(UIColor.systemBackground))
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
    static var exampleCourse: CourseViewModel {
        CourseViewModel(title: "This is an interesting course", itemTitle: "Continue learning")
    }

    static var previews: some View {
        Group {
            ContinueLearningWidgetEntryView(entry: ContinueLearningWidgetEntry(course1: exampleCourse, course2: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            ContinueLearningWidgetEntryView(entry: ContinueLearningWidgetEntry(course1: exampleCourse, course2: exampleCourse))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
