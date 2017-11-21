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

    @discardableResult convenience init<A, B>(origin: A, destination: ResourceIdentifier, destinationType: B.Type, toManyRelationship: Bool, inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable, B: NSManagedObject & Pullable {
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

        guard let destinationEnityName = A.entity().name else {
            throw SynchronizationError.missingEnityNameForResource(B.self)
        }

        self.init(context: context)
        self.originEnityName = originEnityName
        self.originObjectId = origin.id
        self.relationshipName = relationship.name
        self.destinationEnityName = destinationEnityName
        self.destinationObjectId = destination.id
        self.toManyRelationship = toManyRelationship
    }

}
