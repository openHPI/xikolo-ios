//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Stockpile

public final class LastVisit: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var visitDate: Date

    @NSManaged public var item: CourseItem?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastVisit> {
        return NSFetchRequest<LastVisit>(entityName: "LastVisit")
    }

}

extension LastVisit: JSONAPIPullable {

    public static var type: String {
        return "last-visits"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        let newVisitDate = try attributes.value(for: "visit_date") as Date

        let isNewObject = self.objectID.isTemporaryID
        guard isNewObject || newVisitDate > self.visitDate else { return }

        self.visitDate = newVisitDate

        if let relationships = try? object.value(for: "relationships") as JSON {
            try self.updateRelationship(forKeyPath: \Self.item,
                                        forKey: "item",
                                        fromObject: relationships,
                                        with: context)
        }
    }

}
