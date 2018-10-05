//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import SyncEngine

protocol PreloadableCourseItemContent: DetailedCourseItemContent {

    static var contentType: String { get }

}

extension PreloadableCourseItemContent {

    static func preloadContent(forCourse course: Course) -> Future<SyncMultipleResult, XikoloError> {
        return CourseItemHelper.syncCourseItems(forCourse: course, withContentType: self.contentType)
    }

    static func preloadContent(forSection section: CourseSection) -> Future<SyncMultipleResult, XikoloError> {
        return CourseItemHelper.syncCourseItems(forSection: section, withContentType: self.contentType)
    }

}
