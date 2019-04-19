//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

extension NSManagedObjectContext {

    public func fetchSingle<T>(_ fetchRequest: NSFetchRequest<T>) -> Result<T, XikoloError> where T: NSManagedObject {
        do {
            let objects = try self.fetch(fetchRequest)

            guard objects.count < 2 else {
                return .failure(.coreDataObjectNotFound)
            }

            guard let object = objects.first else {
                return .failure(.coreDataMoreThanOneObjectFound)
            }

            return .success(object)
        } catch {
            return .failure(.coreData(error))
        }
    }

    public func fetchMultiple<T>(_ fetchRequest: NSFetchRequest<T>) -> Result<[T], XikoloError> where T: NSManagedObject {
        do {
            let objects = try self.fetch(fetchRequest)
            return .success(objects)
        } catch {
            return .failure(.coreData(error))
        }
    }

    public func typedObject<T>(with id: NSManagedObjectID) -> T where T: NSManagedObject {
        let managedObject = self.object(with: id)
        guard let object = managedObject as? T else {
            let message = "Type mismatch for NSManagedObject (required)"
            let reason = "required: \(T.self), found: \(type(of: managedObject))"
            log.error("%@: %@", message, reason)
            fatalError("\(message): \(reason)")
        }

        return object
    }

    public func existingTypedObject<T>(with id: NSManagedObjectID) -> T? where T: NSManagedObject {
        guard let managedObject = try? self.existingObject(with: id) else {
            log.info("NSManagedObject of type (\(T.self)) could not be retrieved by id (\(id))")
            return nil
        }

        guard let object = managedObject as? T else {
            let message = "Type mismatch for NSManagedObject"
            let reason = "expected: \(T.self), found: \(type(of: managedObject))"
            log.error("\(message): \(reason)")
            return nil
        }

        return object
    }

    public func saveWithResult() -> Result<Void, XikoloError> {
        do {
            if self.hasChanges {
                try self.save()
            }

            return .success(())
        } catch {
            return .failure(.coreData(error))
        }
    }

}
