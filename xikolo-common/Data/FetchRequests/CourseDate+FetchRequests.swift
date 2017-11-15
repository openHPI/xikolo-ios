//
//  CourseDate+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension CourseDate {

    struct FetchRequest {

        static var allCourseDates: NSFetchRequest<CourseDate> {
            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            let courseSort = NSSortDescriptor(key: "course.title", ascending: true)
            let dateSort = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [courseSort, dateSort]
            return request
        }

    }

}
