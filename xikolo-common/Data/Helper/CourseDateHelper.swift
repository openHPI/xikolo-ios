//
//  CourseDateHelper.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 15.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct CourseDateHelper {

    @discardableResult static func syncAllCourseDates() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let query = MultipleResourcesQuery(type: CourseDate.self)
        return SyncHelper.syncResources(withFetchRequest: CourseDateHelper.FetchRequest.allCourseDates, withQuery: query)
    }

}
