//
//  CourseDateHelper.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BrightFutures

struct CourseDateHelper {

    static func syncAllCourseDates() -> Future<[CourseDate], XikoloError> {
        let query = MultipleResourcesQuery(type: CourseDate.self)
        return SyncEngine.syncResources(withFetchRequest: CourseDate.FetchRequest.allCourseDates, withQuery: query)
    }

}
