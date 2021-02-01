//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import WidgetKit

struct NextCourseDateWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> NextCourseDateWidgetEntry {
        let courseDate = CourseDateViewModel(courseTitle: "An interesting course", itemTitle: "Item title", date: Date())
        return NextCourseDateWidgetEntry(courseDate: courseDate, userIsLoggedIn: UserProfileHelper.shared.isLoggedIn)
    }

    func getSnapshot(in context: Context, completion: @escaping (NextCourseDateWidgetEntry) -> ()) {
        CoreDataHelper.persistentContainer.performBackgroundTask { managedObjectContext in
            let nextCourseDate = managedObjectContext.fetchSingle(CourseDateHelper.FetchRequest.nextCourseDate).value
            let courseDateViewModel = nextCourseDate.flatMap(CourseDateViewModel.init(courseDate:))
            let entry = NextCourseDateWidgetEntry(courseDate: courseDateViewModel, userIsLoggedIn: UserProfileHelper.shared.isLoggedIn)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextCourseDateWidgetEntry>) -> ()) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

}

struct NextCourseDateWidgetEntry: TimelineEntry {
    let date: Date = Date()
    let courseDate: CourseDateViewModel?
    let userIsLoggedIn: Bool
}
