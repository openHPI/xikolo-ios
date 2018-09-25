//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Marshal

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

    public func findIncludedObject(forKey key: KeyType, ofObject object: ResourceData) -> FindIncludedObjectResult {
        guard let resourceIdentifier = try? object.value(for: "\(key).data") as ResourceIdentifier else {
            return .notExisting
        }

        guard !self.includedResourceData.isEmpty else {
            return .id(resourceIdentifier.id)
        }

        let includedResource = self.includedResourceData.first { item in
            guard let identifier = try? ResourceIdentifier(object: item) else {
                return false
            }

            return resourceIdentifier.id == identifier.id && resourceIdentifier.type == identifier.type
        }

        guard let resourceData = includedResource else {
            return .id(resourceIdentifier.id)
        }

        return .object(resourceIdentifier.id, resourceData)
    }

    public func findIncludedObjects(forKey key: KeyType, ofObject object: ResourceData) -> FindIncludedObjectsResult {
        guard let resourceIdentifiers = try? object.value(for: "\(key).data") as [ResourceIdentifier] else {
            return .notExisting
        }

        guard !self.includedResourceData.isEmpty else {
            return .included(objects: [], ids: resourceIdentifiers.map { $0.id })
        }

        var resourceData: [(id: String, object: ResourceData)] = []
        var resourceIds: [String] = []
        for resourceIdentifier in resourceIdentifiers {
            let includedData = self.includedResourceData.first { item in
                guard let identifier = try? ResourceIdentifier(object: item) else {
                    return false
                }

                return resourceIdentifier.id == identifier.id && resourceIdentifier.type == identifier.type
            }

            if let includedResource = includedData {
                resourceData.append((id: resourceIdentifier.id, object: includedResource))
            } else {
                resourceIds.append(resourceIdentifier.id)
            }
        }

        return .included(objects: resourceData, ids: resourceIds)
    }

}
