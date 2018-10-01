//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import SyncEngine

public final class Enrollment: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var certificates: EnrollmentCertificates?
    @NSManaged public var proctored: Bool
    @NSManaged public var completed: Bool
    @NSManaged public var reactivated: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var objectStateValue: Int16

    @NSManaged public var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Enrollment> {
        return NSFetchRequest<Enrollment>(entityName: "Enrollment")
    }

    func compare(_ object: Enrollment) -> ComparisonResult {
        // This method is required, because we're using an NSSortDescriptor to sort courses based on enrollment.
        // Since we only rely on sorting enrolled vs. un-enrolled courses, this comparison method considers all enrollments equal,
        // which means they will be sorted by the next attribute in the sort descriptor.
        return .orderedSame
    }

}

extension Enrollment: JSONAPIPullable {

    public static var type: String {
        return "enrollments"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.certificates = try attributes.value(for: "certificates")
        self.proctored = try attributes.value(for: "proctored")
        self.completed = try attributes.value(for: "completed")
        self.reactivated = try attributes.value(for: "reactivated")
        self.createdAt = try attributes.value(for: "created_at")

        guard let relationships = try? object.value(for: "relationships") as JSON else { return }

        try self.updateRelationship(forKeyPath: \Enrollment.course, forKey: "course", fromObject: relationships, with: context)
    }

}

extension Enrollment: JSONAPIPushable {

    public func markAsUnchanged() {
        self.objectState = .unchanged
    }

    public func resourceAttributes() -> [String: Any] {
        return [ "completed": self.completed ]
    }

    public func resourceRelationships() -> [String: AnyObject]? {
        return [ "course": self.course as AnyObject ]
    }

}
