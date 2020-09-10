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

        assert(!self.destinationEntityName.isEmpty, "Invalid key path is used")
        self.relationshipKeyPaths.forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
        self.inverseRelationshipKeyPaths.forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
    }

}

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


public final class RelationshipKeyPathsObserver<Object: NSManagedObject>: NSObject {

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
                        guard let value = object.value(forKey: lastInverseRelationshipKeyPath) else { continue }

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

