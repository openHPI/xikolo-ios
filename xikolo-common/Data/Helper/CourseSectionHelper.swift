//
//  CourseSectionHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 11.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Result

class CourseSectionHelper {

    static func getSectionRequest(_ course: Course) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseSection")
        request.predicate = NSPredicate(format: "course = %@", course)
        let titleSort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [titleSort]
        return request
    }

    static func syncCourseSections(_ course: Course) -> Future<[CourseSection], XikoloError> {
        return CourseSectionProvider.getCourseSections(course.id).flatMap { spineSections -> Future<[BaseModel], XikoloError> in
            let request = getSectionRequest(course)
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineSections, inject: ["course": course], save: true)
        }.map { cdSections in
            return cdSections as! [CourseSection]
        }
    }

}
