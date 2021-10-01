//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import WidgetKit

struct ContinueLearningWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> ContinueLearningWidgetEntry {
        let course = CourseViewModel(title: "This is an interesting course", itemTitle: "Continue learning")
        return ContinueLearningWidgetEntry(course: course, userIsLoggedIn: UserProfileHelper.shared.isLoggedIn)
    }

    func getSnapshot(in context: Context, completion: @escaping (ContinueLearningWidgetEntry) -> Void) {
        CoreDataHelper.persistentContainer.performBackgroundTask { managedObjectContext in
            let currentCourses = managedObjectContext.fetchMultiple(CourseHelper.FetchRequest.enrolledCurrentCoursesRequest).value ?? []
            let lastAccessedCourse = currentCourses.first.map { course -> CourseViewModel in
                let lastVisit = managedObjectContext.fetchSingle(LastVisitHelper.FetchRequest.lastVisit(forCourse: course)).value
                return CourseViewModel(course: course, lastVisit: lastVisit)
            }

            let entry = ContinueLearningWidgetEntry(course: lastAccessedCourse, userIsLoggedIn: UserProfileHelper.shared.isLoggedIn)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ContinueLearningWidgetEntry>) -> Void) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }

}

struct ContinueLearningWidgetEntry: TimelineEntry {
    let date = Date()
    let course: CourseViewModel?
    let userIsLoggedIn: Bool
}
