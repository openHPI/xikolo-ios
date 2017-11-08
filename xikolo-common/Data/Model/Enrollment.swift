//
//  Enrollment.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 26.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

final class Enrollment : NSManagedObject {

    @NSManaged var id: String
//    @NSManaged var visits: EnrollmentVisits?
//    @NSManaged var points: EnrollmentPoints?
    @NSManaged var certificates: EnrollmentCertificates?
    @NSManaged var proctored: Bool
    @NSManaged var completed: Bool
    @NSManaged var reactivated: Bool
    @NSManaged var createdAt: Date?
    @NSManaged var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Enrollment> {
        return NSFetchRequest<Enrollment>(entityName: "Enrollment");
    }

    func compare(_ object: Enrollment) -> ComparisonResult {
        // This method is required, because we're using an NSSortDescriptor to sort courses based on enrollment.
        // Since we only rely on sorting enrolled vs. un-enrolled courses, this comparison method considers all enrollments equal,
        // which means they will be sorted by the next attribute in the sort descriptor.
        return .orderedSame
    }

//    var proctored: Bool {
//        get {
//            return proctored_int?.boolValue ?? false
//        }
//        set(new_is_proctored) {
//            proctored_int = new_is_proctored as NSNumber?
//        }
//    }
//
//    var completed: Bool {
//        get {
//            return completed_int?.boolValue ?? false
//        }
//        set(new_is_completed) {
//            completed_int = new_is_completed as NSNumber?
//        }
//    }
//
//    var reactivated: Bool? {
//        get {
//            return reactivated_int?.boolValue
//        }
//        set(new_is_reactivated) {
//            reactivated_int = new_is_reactivated as NSNumber?
//        }
//    }

}

extension Enrollment : Pullable {

    static var type: String {
        return "enrollments"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON

        //        "visits": EmbeddedObjectAttribute(EnrollmentVisits.self), // TODO: don't use this
        //        "points": EmbeddedObjectAttribute(EnrollmentPoints.self), // TODO: don't use this
//        "certificates": EmbeddedObjectAttribute(EnrollmentCertificates.self),
        self.proctored = try attributes.value(for: "proctored")
        self.completed = try attributes.value(for: "completed")
        self.reactivated = try attributes.value(for: "reactivated")
        self.createdAt = try attributes.value(for: "created_at")
    }

}

//@objcMembers
//class EnrollmentSpine : BaseModelSpine {
//
//    var visits: EnrollmentVisits?
//    var points: EnrollmentPoints?
//    var certificates: EnrollmentCertificates?
//    var proctored_int: NSNumber?
//    var completed_int: NSNumber?
//    var reactivated_int: NSNumber?
//    var created_at: Date?
//
//    var course: CourseSpine?
//
//    //used for PATCH
//    convenience init(course: CourseSpine){
//        self.init()
//        self.course = course
//        self.completed_int = 0
//        //TODO: What about content
//    }
//
//    convenience init(from enrollment: Enrollment){
//        self.init()
//        let course = CourseSpine(course: enrollment.course!)
//        self.course = course
//        self.id = enrollment.id
//        self.completed_int = enrollment.completed_int
//    }
//
//    override class var cdType: BaseModel.Type {
//        return Enrollment.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "enrollments"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "visits": EmbeddedObjectAttribute(EnrollmentVisits.self),
//            "points": EmbeddedObjectAttribute(EnrollmentPoints.self),
//            "certificates": EmbeddedObjectAttribute(EnrollmentCertificates.self),
//            "proctored_int": BooleanAttribute().serializeAs("proctored"),
//            "completed_int": BooleanAttribute().serializeAs("completed"),
//            "reactivated_int": BooleanAttribute().serializeAs("reactivated"),
//            "created_at": DateAttribute(),
//            "course": ToOneRelationship(CourseSpine.self)
//        ])
//    }
//
//}

