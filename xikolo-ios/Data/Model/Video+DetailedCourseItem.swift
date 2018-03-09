//
//  CourseItem+DetailedCourseItem.swift
//  xikolo-ios
//
//  Created by Max Bothe on 20/07/17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

extension Video: DetailedCourseItem {

    static var contentType: String {
        return "video"
    }

    var detailedContent: [DetailedData] {
        var content: [DetailedData] = [
            .video(duration: TimeInterval(self.duration), downloaded: self.localFileBookmark != nil),
        ]

        if self.slidesURL != nil {
            content.append(.slides(downloaded: false))
        }

        return content
    }

    static func preloadContentFor(course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        return CourseItemHelper.syncVideos(forCourse: course)
    }

}
