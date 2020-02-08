//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import SyncEngine

final public class PeerAssessment: Content {

    @NSManaged public var id: String
    @NSManaged public var instructions: String?
    @NSManaged public var type: String?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PeerAssessment> {
        return NSFetchRequest<PeerAssessment>(entityName: "PeerAssessment")
    }

}

extension PeerAssessment: JSONAPIPullable {

    public static var type: String {
        return "peer-assessments"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.instructions = try attributes.value(for: "instructions")
        self.type = try attributes.value(for: "type")
    }

}
