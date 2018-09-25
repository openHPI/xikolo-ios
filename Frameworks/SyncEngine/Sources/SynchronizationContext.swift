//
//  Created for schulcloud-mobile-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

public struct SynchronizationContext {

    let coreDataContext: NSManagedObjectContext
    let strategy: SyncStrategy
    var includedResourceData: [ResourceData] = []


    // TODO: move to DATABASE
    func findExistingResource<Resource>(withId objectId: String,
                                        ofType type: Resource.Type) throws -> Resource? where Resource: NSManagedObject & Pullable {
        guard let entityName = Resource.entity().name else {
            throw SynchronizationError.missingEnityNameForResource(Resource.self)
        }

        let fetchRequest: NSFetchRequest<Resource> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", objectId)

        let objects = try self.coreDataContext.fetch(fetchRequest)

        if objects.count > 1 {
            // TODO: Logging
            //            SyncEngine.log?("Found multiple resources while updating relationship (entity name: \(entityName), \(objectId))", .warning)
        }

        return objects.first
    }

}
