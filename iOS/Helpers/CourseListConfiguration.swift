//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation

enum CourseListConfiguration {
    case allCourses
    case currentCourses
    case completedCourses

    var title: String {
        switch self {
        case .allCourses:
            return NSLocalizedString("course-list.title.Courses", comment: "title for list of all courses")
        case .currentCourses:
            return NSLocalizedString("course-list.title.My current courses", comment: "title for list of current courses")
        case .completedCourses:
            return NSLocalizedString("course-list.title.My completed courses", comment: "title for list of completed courses")
        }
    }

    var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
        return self == .allCourses ? .automatic : .never
    }

    var resultsControllers: [NSFetchedResultsController<Course>] {
        switch self {
        case .allCourses:
            return [
                CoreDataHelper.createResultsController(CourseHelper.FetchRequest.currentCourses, sectionNameKeyPath: "currentSectionName"),
                CoreDataHelper.createResultsController(CourseHelper.FetchRequest.upcomingCourses, sectionNameKeyPath: "upcomingSectionName"),
                CoreDataHelper.createResultsController(CourseHelper.FetchRequest.selfpacedCourses, sectionNameKeyPath: "selfpacedSectionName"),
            ]
        case .currentCourses:
            return [
                CoreDataHelper.createResultsController(CourseHelper.FetchRequest.enrolledCurrentCoursesRequest, sectionNameKeyPath: nil),
            ]
        case .completedCourses:
            return [
                CoreDataHelper.createResultsController(CourseHelper.FetchRequest.completedCourses, sectionNameKeyPath: nil),
            ]
        }
    }

    var searchFetchRequest: NSFetchRequest<Course> {
        switch self {
        case .allCourses:
            return CourseHelper.FetchRequest.accessibleCourses
        case .currentCourses:
            return CourseHelper.FetchRequest.enrolledCurrentCoursesRequest
        case .completedCourses:
            return CourseHelper.FetchRequest.completedCourses
        }
    }

}
