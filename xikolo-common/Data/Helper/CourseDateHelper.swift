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

    static func getCourseDatesRequest() -> NSFetchRequest<CourseDate> {
        let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
        let courseSort = NSSortDescriptor(key: "course.title", ascending: true)
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [courseSort, dateSort]
        return request
    }

    static func getCourseDeadlinesRequest() -> NSFetchRequest<CourseDate> {
        let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
        let courseSort = NSSortDescriptor(key: "course.title", ascending: true)
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        let predicate = NSPredicate(format: "type != 'course_start'")
        request.predicate = predicate
        request.sortDescriptors = [courseSort, dateSort]
        return request
    }

    static func getCourseStartsRequest() -> NSFetchRequest<CourseDate> {
        let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        let predicate = NSPredicate(format: "type = 'course_start'")
        request.predicate = predicate
        request.sortDescriptors = [dateSort]
        return request
    }

    static func syncCourseDates() -> Future<[CourseDate], XikoloError> {
        return CourseDateProvider.getCourseDates().flatMap { spineCourseDates -> Future<[CourseDate], XikoloError> in
            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineCourseDates, inject: nil, save: true)
        }
    }

}
