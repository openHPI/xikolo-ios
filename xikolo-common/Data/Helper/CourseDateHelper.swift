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

    static func syncAllCourseDates() -> Future<[NSManagedObjectID], XikoloError> {
        let query = MultipleResourcesQuery(type: CourseDate.self)
        return SyncEngine.syncResources(withFetchRequest: CourseDateHelper.FetchRequest.allCourseDates, withQuery: query)
    }

}
