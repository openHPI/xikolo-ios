//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation

protocol DetailedCourseItem {

    static var contentType: String { get }

    var detailedContent: [DetailedData] { get }

    static func preloadContent(forCourse course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError>
    static func preloadContent(forSection section: CourseSection) -> Future<SyncEngine.SyncMultipleResult, XikoloError>

}

extension DetailedCourseItem {

    static func preloadContent(forCourse course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        return CourseItemHelper.syncCourseItems(forCourse: course, withContentType: self.contentType)
    }

    static func preloadContent(forSection section: CourseSection) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        return CourseItemHelper.syncCourseItems(forSection: section, withContentType: self.contentType)
    }

}

enum DetailedData {

    case text(readingTime: TimeInterval)  // if we have this, it's always downloaded
    case video(duration: TimeInterval, downloaded: Bool)
    case slides(downloaded: Bool)

    // XXX
    var downloaded: Bool {
        switch self {
        case .text(readingTime: _):
            return true
        case let .video(duration: _, downloaded: downloaded): // XXX rename to stream., remove downloaded
            return downloaded
        case let .slides(downloaded: downloaded): // XX remove downloaded
            return downloaded
        }
    }

}
