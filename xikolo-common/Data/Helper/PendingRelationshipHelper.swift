//
//  PendingRelationshipHelper.swift
//  xikolo-ios
//
//  Created by Max Bothe on 20.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData

struct PendingRelationshipHelper {

    static func conntectResources(withObject destination: NSManagedObject & Pullable) {
        guard let destinationEnityName = type(of: destination).entity().name else {
            print("Error: No entity name for resource: \(type(of: destination).self)")
            return
        }

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<PendingRelationship> = PendingRelationship.fetchRequest()
            let typePredicate = NSPredicate(format: "destinationEnityName = %@", destinationEnityName)
            let idPredicate = NSPredicate(format: "destinationObjectId = %@", destination.id)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, idPredicate])
            do {
                let relationships = try context.fetch(fetchRequest)
                for relationship in relationships {
                    try self.conntectResources(withRelationship: relationship, inContext: context)
                }
                CoreDataHelper.save(context).onFailure { error in
                    print("Error: Failed to save resource connection: \(error)")
                }
            } catch {
                print("Error: Failed to conntect resources: \(error)")
            }
        }
    }

    static func conntectResources(withRelationship relationship: PendingRelationship) {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            do {
                try self.conntectResources(withRelationship: relationship, inContext: context)
                CoreDataHelper.save(context).onFailure { error in
                    print("Error: Failed to save resource connection: \(error)")
                }
            } catch {
                print("Error: Failed to conntect resources: \(error)")
            }
        }
    }

    private static func conntectResources(withRelationship relationship: PendingRelationship, inContext context: NSManagedObjectContext) throws {
        guard let origin = try self.findResource(withEntityName: relationship.originEnityName, withId: relationship.originObjectId, inContext: context) else {
            print("Verbose: No resource found for origin of relationship")
            return
        }

        guard let destination = try self.findResource(withEntityName: relationship.destinationEnityName, withId: relationship.destinationObjectId, inContext: context) else {
            print("Verbose: No resource found for destination of relationship")
            return
        }

        if relationship.toManyRelationship {
            var currentValue = origin.value(forKey: relationship.relationshipName) as? [NSManagedObject] ?? []
            currentValue.append(destination)
            origin.setValue(Set(currentValue), forKey: relationship.relationshipName)
        } else {
            origin.setValue(destination, forKey: relationship.relationshipName)
        }

        context.delete(relationship)
    }

    private static func findResource(withEntityName entityName: String, withId objectId: String, inContext context: NSManagedObjectContext) throws -> NSManagedObject? {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", objectId)

        let objects = try context.fetch(fetchRequest)

        if objects.count > 1 {
            print("Warning: Found multiple resources for pending relationship")
        }

        return objects.first
    }

    static func deletePendingRelationship(forOrigin origin: NSManagedObject & Pullable) {
        guard let originEnityName = type(of: origin).entity().name else {
            print("Error: No entity name for resource: \(type(of: origin).self)")
            return
        }

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<PendingRelationship> = PendingRelationship.fetchRequest()
            let typePredicate = NSPredicate(format: "originEnityName = %@", originEnityName)
            let idPredicate = NSPredicate(format: "originObjectId = %@", origin.id)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, idPredicate])

            do {
                let objects = try context.fetch(fetchRequest)
                for object in objects {
                    context.delete(object)
                }
                CoreDataHelper.save(context).onFailure { error in
                    print("Error: Failed to save deletion of pending relationship: \(error)")
                }
            } catch {
                print("Error: Failed to delete pending relationship: \(error)")
            }
        }
    }

}
