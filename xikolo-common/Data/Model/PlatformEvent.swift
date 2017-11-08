//
//  PlatformEvent.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 07.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import Spine

@objcMembers
final class PlatformEvent : NSManagedObject {

    @NSManaged var id: String
    @NSManaged var createdAt: Date?
    @NSManaged var preview: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlatformEvent> {
        return NSFetchRequest<PlatformEvent>(entityName: "PlatformEvent");
    }

}

extension PlatformEvent : Pullable {

    static var type: String {
        return "platform-events"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.createdAt = try attributes.value(for: "created_at")
        self.preview = try attributes.value(for: "preview")
        self.type = try attributes.value(for: "type")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \PlatformEvent.course, forKey: "course", fromObject: relationships, including: includes, inContext: context)
    }

}

//@objcMembers
//class PlatformEventSpine : BaseModelSpine {
//
//    var created_at: Date?
//    var preview: String?
//    var title: String?
//    var type: String?
//
//    var course: CourseSpine?
//
//    override class var cdType: BaseModel.Type {
//        return PlatformEvent.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "platform-events"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "title": Attribute(),
//            "type": Attribute(),
//            "created_at": DateAttribute(),
//            "preview": Attribute(),
//            "course": ToOneRelationship(CourseSpine.self),
//        ])
//    }
//}

