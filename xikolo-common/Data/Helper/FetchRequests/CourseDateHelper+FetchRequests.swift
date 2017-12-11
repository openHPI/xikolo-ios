//
//  CourseDateHelper+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension CourseDateHelper {

    struct FetchRequest {

        static var allCourseDates: NSFetchRequest<CourseDate> {
            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            let dateSort = NSSortDescriptor(key: "date", ascending: true)
            let courseSort = NSSortDescriptor(key: "course.title", ascending: true)
            let titleSort = NSSortDescriptor(key: "title", ascending: true)
            request.sortDescriptors = [dateSort, courseSort, titleSort]
            return request
        }

    }

}
