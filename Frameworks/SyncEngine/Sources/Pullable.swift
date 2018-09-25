//
//  Created for schulcloud-mobile-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Marshal

public protocol Pullable: ResourceRepresentable {

    static func value(from object: ResourceData, with context: SynchronizationContext) throws -> Self

    mutating func update(from object: ResourceData, with context: SynchronizationContext) throws

}

extension Pullable where Self: NSManagedObject {

    public static func value(from object: ResourceData, with context: SynchronizationContext) throws -> Self {
        try context.strategy.validateObjectCreation(object: object, toHaveType: Self.type)
        var managedObject = self.init(entity: self.entity(), insertInto: context.coreDataContext)
        try managedObject.id = object.value(for: context.strategy.resourceKeyAttribute)
        try managedObject.update(from: object, with: context)
        return managedObject
    }

    public func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               with context: SynchronizationContext) throws where A: NSManagedObject & Pullable {
        switch context.strategy.findIncludedObject(forKey: key, ofObject: object, with: context) {
        case let .object(_, includedObject):
            var existingObject = self[keyPath: keyPath] // TODO: also check if id is equal. update() does not updates the id
            do {
                try existingObject.update(from: includedObject, with: context)
            } catch let error as MarshalError {
                throw NestedMarshalError.nestedMarshalError(error, includeType: A.type, includeKey: key)
            }
        default:
            throw SynchronizationError.missingIncludedResource(from: Self.self, to: A.self, withKey: key)
        }
    }

    public func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A?>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               with context: SynchronizationContext) throws where A: NSManagedObject & Pullable {
        switch context.strategy.findIncludedObject(forKey: key, ofObject: object, with: context) {
        case let .object(resourceId, includedObject):
            do {
                if var existingObject = self[keyPath: keyPath] { // TODO: also check if id is equal. update() does not updates the id
                    try existingObject.update(from: includedObject, with: context)
                } else {
                    if var fetchedResource = try SyncEngine.findExistingResource(withId: resourceId, ofType: A.self, inContext: context.coreDataContext) {
                        try fetchedResource.update(from: includedObject, with: context)
                        self[keyPath: keyPath] = fetchedResource
                    } else {
                        self[keyPath: keyPath] = try A.value(from: includedObject, with: context)
                    }
                }
            } catch let error as MarshalError {
                throw NestedMarshalError.nestedMarshalError(error, includeType: A.type, includeKey: key)
            }
        case let .id(resourceId):
            if let fetchedResource = try SyncEngine.findExistingResource(withId: resourceId, ofType: A.self, inContext: context.coreDataContext) {
                self[keyPath: keyPath] = fetchedResource
            } else {
                SyncEngine.log?("relationship update saved (\(Self.type) --> \(A.type)?)", .info)
            }
        case .notExisting:
            // relationship does not exist, so we reset delete the possible relationship
            self[keyPath: keyPath] = nil
        }
    }

    public func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, Set<A>>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               with context: SynchronizationContext) throws where A: NSManagedObject & Pullable {
        var currentObjects = Set(self[keyPath: keyPath])

        do {
            switch context.strategy.findIncludedObjects(forKey: key, ofObject: object, with: context) {
            case let .included(resourceIdsAndObjects, resourceIds):
                for (resourceId, includedObject) in resourceIdsAndObjects {
                    if var currentObject = currentObjects.first(where: { $0.id == resourceId }) {
                        try currentObject.update(from: includedObject, with: context)
                        if let index = currentObjects.index(where: { $0 == currentObject }) {
                            currentObjects.remove(at: index)
                        }
                    } else {
                        if var fetchedResource = try SyncEngine.findExistingResource(withId: resourceId, ofType: A.self, inContext: context.coreDataContext) {
                            try fetchedResource.update(from: includedObject, with: context)
                            self[keyPath: keyPath].insert(fetchedResource)
                        } else {
                            let newObject = try A.value(from: includedObject, with: context)
                            self[keyPath: keyPath].insert(newObject)
                        }
                    }
                }

                for resourceId in resourceIds {
                    if let currentObject = currentObjects.first(where: { $0.id == resourceId }) {
                        if let index = currentObjects.index(where: { $0 == currentObject }) {
                            currentObjects.remove(at: index)
                        }
                    } else {
                        if let fetchedResource = try SyncEngine.findExistingResource(withId: resourceId, ofType: A.self, inContext: context.coreDataContext) {
                            self[keyPath: keyPath].insert(fetchedResource)
                        }
                    }
                }
            case .notExisting:
                break
            }
        } catch let error as MarshalError {
            throw NestedMarshalError.nestedMarshalError(error, includeType: A.type, includeKey: key)
        }

        // TODO: really?
        for currentObject in currentObjects {
            context.coreDataContext.delete(currentObject)
        }
    }

    public func updateAbstractRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A?>,
                                              forKey key: KeyType,
                                              fromObject object: ResourceData,
                                              with context: SynchronizationContext,
                                              updatingBlock block: (AbstractPullableContainer<Self, A>) throws -> Void) throws {
        let container = AbstractPullableContainer<Self, A>(onResource: self,
                                                           withKeyPath: keyPath,
                                                           forKey: key,
                                                           fromObject: object,
                                                           with: context)
        try block(container)
    }

}

public class AbstractPullableContainer<A, B> where A: NSManagedObject & Pullable, B: NSManagedObject & AbstractPullable {

    let resource: A
    let keyPath: ReferenceWritableKeyPath<A, B?>
    let key: KeyType
    let object: ResourceData
    let context: SynchronizationContext

    init(onResource resource: A,
         withKeyPath keyPath: ReferenceWritableKeyPath<A, B?>,
         forKey key: KeyType,
         fromObject object: ResourceData,
         with context: SynchronizationContext) {
        self.resource = resource
        self.keyPath = keyPath
        self.key = key
        self.object = object
        self.context = context
    }

    public func update<C>(forType type: C.Type) throws where C: NSManagedObject & Pullable {
        let resourceIdentifier = try self.object.value(for: "\(self.key).data") as ResourceIdentifier

        guard resourceIdentifier.type == C.type else { return }

        switch self.context.strategy.findIncludedObject(forKey: self.key, ofObject: self.object, with: self.context) {
        case let .object(_, includedObject):
            do {
                if var existingObject = self.resource[keyPath: self.keyPath] as? C {
                    try existingObject.update(from: includedObject, with: context)
                } else if let newObject = try C.value(from: includedObject, with: context) as? B {
                    self.resource[keyPath: self.keyPath] = newObject
                }
            } catch let error as MarshalError {
                throw NestedMarshalError.nestedMarshalError(error, includeType: C.type, includeKey: key)
            }
        default:
            // TODO throw error?
            break
        }
    }

}

public protocol AbstractPullable {}
