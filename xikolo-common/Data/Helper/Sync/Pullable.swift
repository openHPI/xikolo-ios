//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import CoreData
import Marshal


protocol Pullable: ResourceRepresentable {

    static func value(from object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws -> Self

    mutating func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws

}

extension Pullable where Self: NSManagedObject {

    static func value(from object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws -> Self {
        let resourceType = try object.value(for: "type") as String
        guard resourceType == Self.type else {
            throw SerializationError.resourceTypeMismatch(expected: resourceType, found: Self.type)
        }
        var managedObject = self.init(entity: self.entity(), insertInto: context)
        try managedObject.id = object.value(for: "id")
        try managedObject.update(withObject: object, including: includes, inContext: context)
        return managedObject
    }

    fileprivate func findIncludedObject(for objectIdentifier: ResourceIdentifier, in includes: [ResourceData]?) -> ResourceData? {
        guard let includedData = includes else {
            return nil
        }

        return includedData.first { item in
            guard let identifier = try? ResourceIdentifier(object: item) else {
                return false
            }
            return objectIdentifier.id == identifier.id && objectIdentifier.type == identifier.type
        }
    }


    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               including includes: [ResourceData]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
        let resourceIdentifier = try object.value(for: "\(key).data") as ResourceIdentifier

        if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
            var existingObject = self[keyPath: keyPath]
            do {
                try existingObject.update(withObject: includedObject, including: includes, inContext: context)
            } catch let error as MarshalError {
                throw NestedMarshalError.nestedMarshalError(error, includeType: A.type, includeKey: key)
            }
        } else {
            throw SynchronizationError.missingIncludedResource(from: Self.self, to: A.self, withKey: key)
        }
    }

    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A?>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               including includes: [ResourceData]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
        guard let resourceIdentifier = try? object.value(for: "\(key).data") as ResourceIdentifier else {
            // relationship does not exist, so we reset delete the possible relationship
            self[keyPath: keyPath] = nil
            return
        }

        if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
            do {
                if var existingObject = self[keyPath: keyPath] {
                    try existingObject.update(withObject: includedObject, including: includes, inContext: context)
                } else {
                    if var fetchedResource = try SyncEngine.findExistingResource(withId: resourceIdentifier.id, ofType: A.self, inContext: context) {
                        try fetchedResource.update(withObject: includedObject, including: includes, inContext: context)
                        self[keyPath: keyPath] = fetchedResource
                    } else {
                        self[keyPath: keyPath] = try A.value(from: includedObject, including: includes, inContext: context)
                    }
                }
            } catch let error as MarshalError {
                throw NestedMarshalError.nestedMarshalError(error, includeType: A.type, includeKey: key)
            }
        } else {
            if let fetchedResource = try SyncEngine.findExistingResource(withId: resourceIdentifier.id, ofType: A.self, inContext: context) {
                self[keyPath: keyPath] = fetchedResource
            } else {
                log.info("relationship update saved (\(Self.type) --> \(A.type)?)")
            }
        }
    }

    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, Set<A>>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               including includes: [ResourceData]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
        let resourceIdentifiers = try object.value(for: "\(key).data") as [ResourceIdentifier]
        var currentObjects = Set(self[keyPath: keyPath])

        do {
            for resourceIdentifier in resourceIdentifiers {
                if var currentObject = currentObjects.first(where: { $0.id == resourceIdentifier.id }) {
                    if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
                        try currentObject.update(withObject: includedObject, including: includes, inContext: context)
                    }

                    if let index = currentObjects.index(where: { $0 == currentObject }) {
                        currentObjects.remove(at: index)
                    }
                } else {
                    if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
                        if var fetchedResource = try SyncEngine.findExistingResource(withId: resourceIdentifier.id, ofType: A.self, inContext: context) {
                            try fetchedResource.update(withObject: includedObject, including: includes, inContext: context)
                            self[keyPath: keyPath].insert(fetchedResource)
                        } else {
                            let newObject = try A.value(from: includedObject, including: includes, inContext: context)
                            self[keyPath: keyPath].insert(newObject)
                        }
                    } else {
                        if let fetchedResource = try SyncEngine.findExistingResource(withId: resourceIdentifier.id, ofType: A.self, inContext: context) {
                            self[keyPath: keyPath].insert(fetchedResource)
                        } else {
                            log.info("relationship update saved (\(Self.type) --> Set<\(A.type)>)")
                        }
                    }
                }
            }
        } catch let error as MarshalError {
            throw NestedMarshalError.nestedMarshalError(error, includeType: A.type, includeKey: key)
        }

        for currentObject in currentObjects {
            context.delete(currentObject)
        }
    }

    func updateAbstractRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A?>,
                                       forKey key: KeyType,
                                       fromObject object: ResourceData,
                                       including includes: [ResourceData]?,
                                       inContext context: NSManagedObjectContext,
                                       updatingBlock block: (AbstractPullableContainer<Self, A>) throws -> Void) throws {
        let container = AbstractPullableContainer<Self, A>(onResource: self, withKeyPath: keyPath, forKey: key, fromObject: object, including: includes, inContext: context)
        try block(container)
    }

}

class AbstractPullableContainer<A, B> where A: NSManagedObject & Pullable, B: NSManagedObject & AbstractPullable {
    let resource: A
    let keyPath: ReferenceWritableKeyPath<A, B?>
    let key: KeyType
    let object: ResourceData
    let includes: [ResourceData]?
    let context: NSManagedObjectContext

    init(onResource resource: A,
         withKeyPath keyPath: ReferenceWritableKeyPath<A, B?>,
         forKey key: KeyType,
         fromObject object: ResourceData,
         including includes: [ResourceData]?,
         inContext context: NSManagedObjectContext) {
        self.resource = resource
        self.keyPath = keyPath
        self.key = key
        self.object = object
        self.includes = includes
        self.context = context
    }

    func update<C>(forType type: C.Type) throws where C: NSManagedObject & Pullable {
        let resourceIdentifier = try self.object.value(for: "\(self.key).data") as ResourceIdentifier

        guard resourceIdentifier.type == C.type else { return }

        if let includedObject = self.resource.findIncludedObject(for: resourceIdentifier, in: self.includes) {
            do {
                if var existingObject = self.resource[keyPath: self.keyPath] as? C{
                    try existingObject.update(withObject: includedObject, including: includes, inContext: context)
                } else if let newObject = try C.value(from: includedObject, including: includes, inContext: context) as? B {
                    self.resource[keyPath: self.keyPath] = newObject
                }
            } catch let error as MarshalError {
                throw NestedMarshalError.nestedMarshalError(error, includeType: C.type, includeKey: key)
            }
        }
    }

}

protocol AbstractPullable {}
