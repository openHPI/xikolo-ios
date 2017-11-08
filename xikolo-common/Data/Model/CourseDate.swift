//
//  CourseDate.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 09.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import Spine

final class CourseDate : BaseModel {

    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var type: String
    @NSManaged var date: Date
    @NSManaged var course: Course

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseDate> {
        return NSFetchRequest<CourseDate>(entityName: "CourseDate");
    }

}

extension CourseDate : Pullable {

    static var type: String {
        return "course-dates"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.type = try attributes.value(for: "type")
        self.date = try attributes.value(for: "date")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \CourseDate.course, forKey: "course", fromObject: relationships, including: includes, inContext: context)
    }

}

//@objcMembers
//class CourseDateSpine : BaseModelSpine {
//
//    var type: String?
//    var title: String?
//    var date: Date?
//
//    var course: CourseSpine?
//
//    override class var resourceType: ResourceType {
//        return "course-dates"
//    }
//
//    override class var cdType: BaseModel.Type {
//        return CourseDate.self
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "type": Attribute(),
//            "title": Attribute(),
//            "date": DateAttribute(),
//            "course": ToOneRelationship(CourseSpine.self)
//        ])
//    }
//
//}

