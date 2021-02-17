//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import WidgetKit

struct CourseDateOverviewWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> CourseDateOverviewWidgetEntry {
        let courseDateOverview = CourseDateStatisticsViewModel(todayCount: 1, nextCount: 2, allCount: 4)
        let nextCourseDate = CourseDateViewModel(courseTitle: "An interesting course", itemTitle: "Course Date title", date: Date())
        return CourseDateOverviewWidgetEntry(courseDateStatistics: courseDateOverview,
                                             nextCourseDate: nextCourseDate,
                                             userIsLoggedIn: UserProfileHelper.shared.isLoggedIn)
    }

    func getSnapshot(in context: Context, completion: @escaping (CourseDateOverviewWidgetEntry) -> Void) {
        CoreDataHelper.persistentContainer.performBackgroundTask { managedObjectContext in
            do {
                let todayCount = try managedObjectContext.count(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 1))
                let nextCount = try managedObjectContext.count(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 7))
                let allCount = try managedObjectContext.count(for: CourseDateHelper.FetchRequest.allCourseDates)
                let courseDate = managedObjectContext.fetchSingle(CourseDateHelper.FetchRequest.nextCourseDate).value

                let courseDateStatistics = CourseDateStatisticsViewModel(todayCount: todayCount, nextCount: nextCount, allCount: allCount)
                let nextCourseDate = courseDate.map(CourseDateViewModel.init(courseDate:))
                let entry = CourseDateOverviewWidgetEntry(courseDateStatistics: courseDateStatistics,
                                                          nextCourseDate: nextCourseDate,
                                                          userIsLoggedIn: UserProfileHelper.shared.isLoggedIn)
                completion(entry)
            } catch {
                let courseDateStatistics = CourseDateStatisticsViewModel(todayCount: 0, nextCount: 0, allCount: 0)
                let entry = CourseDateOverviewWidgetEntry(courseDateStatistics: courseDateStatistics,
                                                          nextCourseDate: nil,
                                                          userIsLoggedIn: UserProfileHelper.shared.isLoggedIn)
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CourseDateOverviewWidgetEntry>) -> Void) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }

    func reloadPolicy(for entry: CourseDateOverviewWidgetEntry) -> TimelineReloadPolicy {
        if let date = entry.nextCourseDate?.date {
            return .after(date)
        } else {
            return .never
        }
    }

}

struct CourseDateOverviewWidgetEntry: TimelineEntry {
    let date = Date()
    let courseDateStatistics: CourseDateStatisticsViewModel
    let nextCourseDate: CourseDateViewModel?
    let userIsLoggedIn: Bool
}
