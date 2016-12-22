//
//  CourseDateHelper.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 15.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData

class CourseDateHelper {

    static func getCourseDatesRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseDate")
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [dateSort]
        return request
    }

    static func getCourseDeadlinesRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseDate")
        let courseSort = NSSortDescriptor(key: "course.title", ascending: true)
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        let predicate = NSPredicate(format: "type != 'course_start'")
        request.predicate = predicate
        request.sortDescriptors = [courseSort, dateSort]
        return request
    }

    static func getCourseStartsRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseDate")
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        let predicate = NSPredicate(format: "type = 'course_start'")
        request.predicate = predicate
        request.sortDescriptors = [dateSort]
        return request
    }

    static func syncCourseDates() -> Future<[CourseDate], XikoloError> {
        return CourseDateProvider.getCourseDates().flatMap { spineCourseDates -> Future<[BaseModel], XikoloError> in
            let request = getCourseDatesRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineCourseDates, inject: nil, save: true)
            }.map { cdCourseDates in
                return cdCourseDates as! [CourseDate]
        }
    }

}
