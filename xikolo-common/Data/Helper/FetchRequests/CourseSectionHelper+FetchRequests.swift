//
//  CourseSection+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension CourseSection {

    struct FetchRequest {

        static func courseSections(forCourse course: Course) -> NSFetchRequest<CourseSection> {
            let request: NSFetchRequest<CourseSection> = CourseSection.fetchRequest()
            let coursePredicate = NSPredicate(format: "course = %@", course)
            let accessiblePredicate = NSPredicate(format: "accessible == true")
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [coursePredicate, accessiblePredicate])
            let positionSort = NSSortDescriptor(key: "position", ascending: true)
            request.sortDescriptors = [positionSort]
            return request
        }

    }

}
