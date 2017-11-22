//
//  CourseSectionHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 11.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct CourseSectionHelper {

    static func syncCourseSections(forCourse course: Course) -> Future<[NSManagedObjectID], XikoloError> {
        let fetchRequest = CourseSectionHelper.FetchRequest.allCourseSections(forCourse: course)
        var query = MultipleResourcesQuery(type: CourseSection.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}

//import BrightFutures
//import CoreData
//
//class CourseSectionHelper {
//
//    static func getSectionRequest(_ course: Course) -> NSFetchRequest<CourseSection> {
//        let request: NSFetchRequest<CourseSection> = CourseSection.fetchRequest()
//        let coursePredicate = NSPredicate(format: "course = %@", course)
//        let accessiblePredicate = NSPredicate(format: "accessible_int == true")
//        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [coursePredicate, accessiblePredicate])
//        let positionSort = NSSortDescriptor(key: "position", ascending: true)
//        request.sortDescriptors = [positionSort]
//        return request
//    }
//
//    static func syncCourseSections(_ course: Course) -> Future<[CourseSection], XikoloError> {
//        return CourseSectionProvider.getCourseSections(course.id).flatMap { spineSections -> Future<[CourseSection], XikoloError> in
//            let request = getSectionRequest(course)
//            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineSections, inject: ["course": course], save: true)
//        }
//    }
//
//}

