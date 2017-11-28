//
//  PendingRelationship.swift
//  xikolo-ios
//
//  Created by Max Bothe on 20.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData
import Foundation

final class PendingRelationship: NSManagedObject {

    @NSManaged var originEnityName: String
    @NSManaged var originObjectId: String
    @NSManaged var relationshipName: String
    @NSManaged var destinationEnityName: String
    @NSManaged var destinationObjectId: String
    @NSManaged var toManyRelationship: Bool

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PendingRelationship> {
        return NSFetchRequest<PendingRelationship>(entityName: "PendingRelationship");
    }

    @discardableResult static func relationship<A, B>(forOrigin origin: A, destination: ResourceIdentifier, destinationType: B.Type, toManyRelationship: Bool, inContext context: NSManagedObjectContext) throws -> PendingRelationship where A: NSManagedObject & Pullable, B: NSManagedObject & Pullable {
        let relationships = origin.entity.relationships(forDestination: B.entity())

        guard let relationship = relationships.first else {
            throw SynchronizationError.noRelationshipBetweenEnities(from: A.self, to: B.self)
        }

        guard relationships.count == 1 else {
            throw SynchronizationError.toManyRelationshipBetweenEnities(from: A.self, to: B.self)
        }

        guard let originEnityName = A.entity().name else {
            throw SynchronizationError.missingEnityNameForResource(A.self)
        }

        guard let destinationEnityName = B.entity().name else {
            throw SynchronizationError.missingEnityNameForResource(B.self)
        }

        return self.findOrCreateRelationship(originEnityName: originEnityName,
                                             originObjectId: origin.id,
                                             relationshipName: relationship.name,
                                             destinationEnityName: destinationEnityName,
                                             destinationObjectId: destination.id,
                                             toManyRelationship: toManyRelationship,
                                             inContext: context)
    }

    @discardableResult static func relationship<A, B, C>(forOrigin origin: A,
                                                         destination: ResourceIdentifier,
                                                         destinationType: B.Type,
                                                         abstractType: C.Type,
                                                         toManyRelationship: Bool,
                                                         inContext context: NSManagedObjectContext) throws -> PendingRelationship where A: NSManagedObject & Pullable, B: NSManagedObject & Pullable, C: NSManagedObject & AbstractPullable {
        guard B.self is C.Type else {
            throw SynchronizationError.noMatchAbstractType(resourceType: B.self, abstractType: C.self)
        }

        let relationships = origin.entity.relationships(forDestination: B.entity())

        guard let relationship = relationships.first else {
            throw SynchronizationError.noRelationshipBetweenEnities(from: A.self, to: C.self)
        }

        guard relationships.count == 1 else {
            throw SynchronizationError.toManyRelationshipBetweenEnities(from: A.self, to: C.self)
        }

        guard let originEnityName = A.entity().name else {
            throw SynchronizationError.missingEnityNameForResource(A.self)
        }

        guard let destinationEnityName = B.entity().name else {
            throw SynchronizationError.missingEnityNameForResource(B.self)
        }

        return self.findOrCreateRelationship(originEnityName: originEnityName,
                                             originObjectId: origin.id,
                                             relationshipName: relationship.name,
                                             destinationEnityName: destinationEnityName,
                                             destinationObjectId: destination.id,
                                             toManyRelationship: toManyRelationship,
                                             inContext: context)
    }

    private static func findOrCreateRelationship(originEnityName: String, originObjectId: String, relationshipName: String, destinationEnityName: String, destinationObjectId: String, toManyRelationship: Bool, inContext context: NSManagedObjectContext) -> PendingRelationship {
        let fetchRequest: NSFetchRequest<PendingRelationship> = PendingRelationship.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "originEnityName = %@", originEnityName),
            NSPredicate(format: "originObjectId = %@", originObjectId),
            NSPredicate(format: "relationshipName = %@", relationshipName),
            NSPredicate(format: "destinationEnityName = %@", destinationEnityName),
            NSPredicate(format: "destinationObjectId = %@", destinationObjectId),
            NSPredicate(format: "toManyRelationship = %@", NSNumber(booleanLiteral: toManyRelationship)),
        ])

        switch context.fetchSingle(fetchRequest) {
        case .success(let relationship):
            return relationship
        case .failure(_):
            let pendingRelationship = self.init(context: context)
            pendingRelationship.originEnityName = originEnityName
            pendingRelationship.originObjectId = originObjectId
            pendingRelationship.relationshipName = relationshipName
            pendingRelationship.destinationEnityName = destinationEnityName
            pendingRelationship.destinationObjectId = destinationObjectId
            pendingRelationship.toManyRelationship = toManyRelationship
            return pendingRelationship
        }
    }

}
