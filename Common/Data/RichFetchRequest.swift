//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

/// Describes a relationship key path for a Core Data entity.
public struct RelationshipKeyPath: Hashable {

    /// The destination property name we're observing
    let destinationPropertyName: String

    let destinationEntityName: String

    let relationshipKeyPaths: [String]

    /// The inverse property names of this relationship. Can be used to get the affected object IDs.
    let inverseRelationshipKeyPaths: [String]

    public init(keyPath: String, relationships: [String: NSRelationshipDescription]?) {
        let splittedKeyPath = keyPath.split(separator: ".").map(String.init)

        var destinationEntity: NSEntityDescription?
        var relationships2: [NSRelationshipDescription?] = []
        var inverseRelationship: [NSRelationshipDescription?] = []
        var destinationProperty: NSPropertyDescription?

        var relationshipsByName: [String: NSRelationshipDescription]? = relationships
        var propertiesByName: [String: NSPropertyDescription]? = [:]
        for relationshipName in splittedKeyPath {
            if let relationship = relationshipsByName?[relationshipName] {
                destinationEntity = relationship.destinationEntity
                relationships2.append(relationship)
                inverseRelationship.append(relationship.inverseRelationship)
                relationshipsByName = relationship.destinationEntity?.relationshipsByName
                propertiesByName = relationship.destinationEntity?.propertiesByName
            } else if let property = propertiesByName?[relationshipName] {
                destinationProperty = property
            } else {
                assertionFailure("Invalid key path is used")
            }
        }

        self.destinationEntityName = destinationEntity?.name ?? ""
        self.destinationPropertyName = destinationProperty?.name ?? ""
        self.relationshipKeyPaths = relationships2.map { $0?.name ?? "" }
        self.inverseRelationshipKeyPaths = inverseRelationship.map { $0?.name ?? "" }

//        assert(!self.destinationPropertyName.isEmpty, "Invalid key path is used")
        assert(!self.destinationEntityName.isEmpty, "Invalid key path is used")
        self.relationshipKeyPaths.forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
        self.inverseRelationshipKeyPaths.forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
    }

}

///// Observes relationship key paths and refreshes Core Data objects accordingly once the related managed object context saves.
//public final class RelationshipKeyPathsObserver<ResultType: NSFetchRequestResult>: NSObject {
//
//    private let keyPaths: Set<RelationshipKeyPath>
//    private weak var fetchedResultsController: NSFetchedResultsController<ResultType>?
//
//    private var updatedObjectIDs: Set<NSManagedObjectID> = []
//
//    public init?(fetchedResultsController: NSFetchedResultsController<ResultType>, keyPaths: Set<String>) {
//        guard !keyPaths.isEmpty else { return nil }
//
//        self.fetchedResultsController = fetchedResultsController
//        let relationships = fetchedResultsController.fetchRequest.entity?.relationshipsByName
//        self.keyPaths = Set(keyPaths.map { keyPath in
//            return RelationshipKeyPath(keyPath: keyPath, relationships: relationships)
//        })
//
//        super.init()
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(contextDidChangeNotification(notification:)),
//                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
//                                               object: fetchedResultsController.managedObjectContext)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(contextDidSaveNotification(notification:)),
//                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
//                                               object: fetchedResultsController.managedObjectContext)
//    }
//
//    @objc private func contextDidChangeNotification(notification: NSNotification) {
//        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
//            guard let updatedObjectIDs = updatedObjects.updatedObjectIDs(for: self.keyPaths), !updatedObjectIDs.isEmpty else { return }
//            self.updatedObjectIDs = self.updatedObjectIDs.union(updatedObjectIDs)
//        }
//
//        if let updatedObjects = notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject> {
//            updatedObjects.forEach { object in
//                guard let changedRelationshipKeyPath = object.changedKeyPath(from: self.keyPaths, refreshed: true) else { return }
//
//                let firstKeyPath = changedRelationshipKeyPath.relationshipKeyPaths.first ?? ""
//
//                var inverseRelationshipKeyPaths: [String] = changedRelationshipKeyPath.inverseRelationshipKeyPaths.reversed()
//                let lastInverseRelationshipKeyPath = inverseRelationshipKeyPaths.popLast() ?? ""
//
//                var objects: Set<NSManagedObject> = [object]
//
//                for inverseRelationshipKeyPath in inverseRelationshipKeyPaths {
//                    let values = objects.compactMap { object in object.value(forKey: inverseRelationshipKeyPath) }
//                    objects.removeAll()
//
//                    for value in values {
//                        if let toManyObjects = value as? Set<NSManagedObject> {
//                            objects.formUnion(toManyObjects)
//                        } else if let toOneObject = value as? NSManagedObject {
//                            objects.insert(toOneObject)
//                        } else {
//                            assertionFailure("Invalid relationship observed for keyPath: \(changedRelationshipKeyPath)")
//                            return
//                        }
//                    }
//                }
//
//                let fetchObjects = self.fetchedResultsController.fetchedObjects as? [NSManagedObject]
//                let fetchObjectIDs = fetchObjects?.map(\.objectID) ?? []
//
//                self.fetchedResultsController?.managedObjectContext.performAndWait {
//                    for object in objects {
//                        let value = object.value(forKey: lastInverseRelationshipKeyPath)
//
//                        if let toManyObjects = value as? Set<NSManagedObject> {
//                            for obj in toManyObjects where fetchObjectIDs.contains(obj.objectID) {
//                                obj.setValue(object, forKeyPath: firstKeyPath)
//                            }
//                        } else if let toOneObject = value as? NSManagedObject, fetchObjectIDs.contains(toOneObject.objectID) {
//                            toOneObject.setValue(object, forKeyPath: firstKeyPath)
//                        } else {
//                            assertionFailure("Invalid relationship observed for keyPath: \(lastInverseRelationshipKeyPath)")
//                            return
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    @objc private func contextDidSaveNotification(notification: NSNotification) {
//        guard !self.updatedObjectIDs.isEmpty else { return }
//        guard let fetchedObjects = self.fetchedResultsController?.fetchedObjects as? [NSManagedObject], !fetchedObjects.isEmpty else { return }
//
//        fetchedObjects.forEach { object in
//            guard self.updatedObjectIDs.contains(object.objectID) else { return }
//            self.fetchedResultsController?.managedObjectContext.refresh(object, mergeChanges: true)
//        }
//
//        self.updatedObjectIDs.removeAll()
//    }
//
//}

//extension Set where Element: NSManagedObject {
//
//    /// Iterates over the objects and returns the object IDs that matched our observing keyPaths.
//    /// - Parameter keyPaths: The keyPaths to observe changes for.
//    func updatedObjectIDs(for keyPaths: Set<RelationshipKeyPath>, refreshed: Bool = false) -> Set<NSManagedObjectID>? {
//        var objectIDs: Set<NSManagedObjectID> = []
//        self.forEach { object in
//            guard let changedRelationshipKeyPath = object.changedKeyPath(from: keyPaths, refreshed: refreshed) else { return }
//
//            let inverseRelationshipKeyPaths = changedRelationshipKeyPath.inverseRelationshipKeyPaths.reversed()
//
//            var objects: Set<NSManagedObject> = [object]
//
//            for inverseRelationshipKeyPath in inverseRelationshipKeyPaths {
//                let values = objects.map { object in object.value(forKey: inverseRelationshipKeyPath) }
//                objects.removeAll()
//
//                for value in values {
//                    if let toManyObjects = value as? Set<NSManagedObject> {
//                        objects.formUnion(toManyObjects)
//                    } else if let toOneObject = value as? NSManagedObject {
//                        objects.insert(toOneObject)
//                    } else {
//                        assertionFailure("Invalid relationship observed for keyPath: \(changedRelationshipKeyPath)")
//                        return
//                    }
//                }
//            }
//
//            objectIDs.formUnion(objects.map(\.objectID))
//        }
//
//        return objectIDs
//    }
//
//}

private extension NSManagedObject {

    /// Matches the given key paths to the current changes of this `NSManagedObject`.
    /// - Parameter keyPaths: The key paths to match the changes for.
    /// - Returns: The matching relationship key path if found. Otherwise, `nil`.
    func changedKeyPath(from keyPaths: Set<RelationshipKeyPath>, refreshed: Bool) -> RelationshipKeyPath? {
        return keyPaths.first { keyPath -> Bool in
            guard keyPath.destinationEntityName == entity.name || keyPath.destinationEntityName == entity.superentity?.name else { return false }
            return refreshed || changedValues().keys.contains(keyPath.destinationPropertyName)
        }
    }

}



public final class RelationshipKeyPathsObserver2<Object: NSManagedObject>: NSObject {

    private let keyPaths: Set<RelationshipKeyPath>

    public init?(for entityType: Object.Type, managedObjectContext: NSManagedObjectContext, keyPaths: Set<String>) {
        guard !keyPaths.isEmpty else { return nil }

        let relationships = entityType.entity().relationshipsByName
        self.keyPaths = Set(keyPaths.compactMap { keyPath in
            return RelationshipKeyPath(keyPath: keyPath, relationships: relationships)
        })

        super.init()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidChangeNotification(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: managedObjectContext)
    }

    @objc private func contextDidChangeNotification(notification: NSNotification) {
        guard let managedObjectContext = notification.object as? NSManagedObjectContext else { return }

        if let updatedObjects = notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject> {
            updatedObjects.forEach { object in
                guard let changedRelationshipKeyPath = object.changedKeyPath(from: self.keyPaths, refreshed: true) else { return }

                let firstKeyPath = changedRelationshipKeyPath.relationshipKeyPaths.first ?? ""

                var inverseRelationshipKeyPaths: [String] = changedRelationshipKeyPath.inverseRelationshipKeyPaths.reversed()
                let lastInverseRelationshipKeyPath = inverseRelationshipKeyPaths.popLast() ?? ""

                var objects: Set<NSManagedObject> = [object]

                for inverseRelationshipKeyPath in inverseRelationshipKeyPaths {
                    let values = objects.compactMap { object in object.value(forKey: inverseRelationshipKeyPath) }
                    objects.removeAll()

                    for value in values {
                        if let toManyObjects = value as? Set<NSManagedObject> {
                            objects.formUnion(toManyObjects)
                        } else if let toOneObject = value as? NSManagedObject {
                            objects.insert(toOneObject)
                        } else {
                            assertionFailure("Invalid relationship observed for keyPath: \(changedRelationshipKeyPath)")
                            return
                        }
                    }
                }

                managedObjectContext.performAndWait {
                    for object in objects {
                        let value = object.value(forKey: lastInverseRelationshipKeyPath)

                        if let toManyObjects = value as? Set<NSManagedObject> {
                            toManyObjects.forEach { $0.setValue(object, forKeyPath: firstKeyPath) }
                        } else if let toOneObject = value as? NSManagedObject {
                            toOneObject.setValue(object, forKeyPath: firstKeyPath)
                        } else {
                            assertionFailure("Invalid relationship observed for keyPath: \(lastInverseRelationshipKeyPath)")
                            return
                        }
                    }
                }
            }
        }
    }

}

