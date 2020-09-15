//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Marshal

public protocol Pullable: ResourceRepresentable, Validatable {

    static func value(from object: ResourceData, with context: SynchronizationContext) throws -> Self
    mutating func update(from object: ResourceData, with context: SynchronizationContext) throws

    // strategy
    static var resourceKeyAttribute: String { get }

    static func queryItems<Query>(forQuery query: Query) -> [URLQueryItem] where Query: ResourceQuery
    static func validateObjectCreation(object: ResourceData) throws
    static func extractResourceData(from object: ResourceData) throws -> ResourceData
    static func extractResourceData(from object: ResourceData) throws -> [ResourceData]
    static func extractIncludedResourceData(from object: ResourceData) -> [ResourceData]

}

extension Pullable where Self: NSManagedObject {

    public static func value(from object: ResourceData, with context: SynchronizationContext) throws -> Self {
        try Self.validateObjectCreation(object: object)
        var managedObject = self.init(entity: self.entity(), insertInto: context.coreDataContext)
        try managedObject.id = object.value(for: Self.resourceKeyAttribute)
        try managedObject.update(from: object, with: context)
        return managedObject
    }

    public func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A>,
                                      forKey key: KeyType,
                                      fromObject object: ResourceData,
                                      with context: SynchronizationContext) throws where A: NSManagedObject & Pullable {
        switch context.findIncludedObject(forKey: key, ofObject: object) {
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
        switch context.findIncludedObject(forKey: key, ofObject: object) {
        case let .object(resourceId, includedObject):
            do {
                if var existingObject = self[keyPath: keyPath] { // TODO: also check if id is equal. update() does not updates the id
                    try existingObject.update(from: includedObject, with: context)
                } else {
                    if var fetchedResource = try context.findExistingResource(withId: resourceId, ofType: A.self) {
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
            if let fetchedResource = try context.findExistingResource(withId: resourceId, ofType: A.self) {
                self[keyPath: keyPath] = fetchedResource
            } else {
                self[keyPath: keyPath] = nil
                // TODO: logging
                // SyncEngine.log?("relationship update saved (\(Self.type) --> \(A.type)?)", .info)
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
            switch context.findIncludedObjects(forKey: key, ofObject: object) {
            case let .included(resourceIdsAndObjects, resourceIds):
                for (resourceId, includedObject) in resourceIdsAndObjects {
                    if var currentObject = currentObjects.first(where: { $0.id == resourceId }) {
                        try currentObject.update(from: includedObject, with: context)
                        if let index = currentObjects.firstIndex(where: { $0 == currentObject }) {
                            currentObjects.remove(at: index)
                        }
                    } else {
                        if var fetchedResource = try context.findExistingResource(withId: resourceId, ofType: A.self) {
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
                        if let index = currentObjects.firstIndex(where: { $0 == currentObject }) {
                            currentObjects.remove(at: index)
                        }
                    } else {
                        if let fetchedResource = try context.findExistingResource(withId: resourceId, ofType: A.self) {
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

        switch self.context.findIncludedObject(forKey: self.key, ofObject: self.object) {
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
