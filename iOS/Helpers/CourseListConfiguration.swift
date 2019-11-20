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
    case coursesInChannel(_ channel: Channel)

    var title: String? {
        switch self {
        case .allCourses:
            return NSLocalizedString("course-list.title.Courses", comment: "title for list of all courses")
        case .currentCourses:
            return NSLocalizedString("course-list.title.My current courses", comment: "title for list of current courses")
        case .completedCourses:
            return NSLocalizedString("course-list.title.My completed courses", comment: "title for list of completed courses")
        case let .coursesInChannel(channel):
            return channel.title
        }
    }

    var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
        switch self {
        case .allCourses:
            return .automatic
        case .currentCourses:
            return .never
        case .completedCourses:
            return .never
        case .coursesInChannel:
            return .never
        }
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
        case let .coursesInChannel(channel):
            return [
                CoreDataHelper.createResultsController(CourseHelper.FetchRequest.currentCourses(for: channel), sectionNameKeyPath: "currentSectionName"),
                CoreDataHelper.createResultsController(CourseHelper.FetchRequest.upcomingCourses(for: channel), sectionNameKeyPath: "upcomingSectionName"),
                CoreDataHelper.createResultsController(CourseHelper.FetchRequest.selfpacedCourses(for: channel), sectionNameKeyPath: "selfpacedSectionName"),
            ]
        }
    }

    var searchFetchRequest: NSFetchRequest<Course> {
        switch self {
        case .allCourses:
            return CourseHelper.FetchRequest.searchableCourses
        case .currentCourses:
            return CourseHelper.FetchRequest.enrolledCurrentCoursesRequest
        case .completedCourses:
            return CourseHelper.FetchRequest.completedCourses
        case let .coursesInChannel(channel):
            return CourseHelper.FetchRequest.searchableCourses(for: channel)
        }
    }

    var shouldShowHeader: Bool {
        switch self {
        case .allCourses:
            return true
        case .currentCourses:
            return false
        case .completedCourses:
            return false
        case .coursesInChannel:
            return true
        }
    }

    var shouldShowGlobalHeader: Bool {
        switch self {
        case .allCourses:
            return false
        case .currentCourses:
            return false
        case .completedCourses:
            return false
        case .coursesInChannel:
            return true
        }
    }

    var containsOnlyEnrolledCourses: Bool {
        switch self {
        case .allCourses:
            return false
        case .currentCourses:
            return true
        case .completedCourses:
            return true
        case .coursesInChannel:
            return false
        }
    }

//    var color: UIColor? {
//        if case let .coursesInChannel(channel) = self { // TODO: chain?
//            return channel.color
//        }
//
//        return nil
//    }

    func colorWithFallback(to fallbackColor: UIColor) -> UIColor {
        if case let .coursesInChannel(channel) = self { // TODO: chain?
            return channel.colorWithFallback(to: fallbackColor)
        }

        return fallbackColor
    }

}
