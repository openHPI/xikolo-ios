//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

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
        guard let updatedObjects = notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject> else { return }

        updatedObjects.forEach { object in
            guard let changedRelationshipKeyPath = object.changedKeyPath(from: self.keyPaths, refreshed: true) else { return }

            let firstKeyPath = changedRelationshipKeyPath.relationshipKeyPaths.first ?? ""

            var inverseRelationshipKeyPaths: [String] = changedRelationshipKeyPath.inverseRelationshipKeyPaths.reversed()
            let lastInverseRelationshipKeyPath = inverseRelationshipKeyPaths.popLast() ?? ""

            var objects: Set<NSManagedObject> = [object]
            objects = objects.objects(whenFollowingKeyPaths: inverseRelationshipKeyPaths)

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

private extension Set where Element: NSManagedObject {

    /// Follow the given key paths to get from one set of object to a another
    /// - Parameter keyPaths: The key paths to follow
    /// - Returns: The objects when following the given key paths
    func objects(whenFollowingKeyPaths keyPaths: [String]) -> Set<NSManagedObject> {
        var objects: Set<NSManagedObject> = self

        for keyPath in keyPaths {
            let values = objects.compactMap { object in object.value(forKey: keyPath) }
            objects.removeAll()

            for value in values {
                if let toManyObjects = value as? Set<NSManagedObject> {
                    objects.formUnion(toManyObjects)
                } else if let toOneObject = value as? NSManagedObject {
                    objects.insert(toOneObject)
                } else {
                    assertionFailure("Invalid relationship when following keyPaths: \(keyPaths) at '\(keyPath)'")
                }
            }
        }

        return objects
    }

}
