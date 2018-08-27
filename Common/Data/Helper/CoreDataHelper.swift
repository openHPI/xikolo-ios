//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Result

public class CoreDataHelper {

    public static var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: CoreDataHelper.self)
        let modelURL = bundle.url(forResource: "xikolo", withExtension: "momd").require()
        let model = NSManagedObjectModel(contentsOf: modelURL).require()
        let container = NSPersistentContainer(name: "xikolo", managedObjectModel: model)

        container.loadPersistentStores { _, error in
            if let error = error {
                log.severe("Unresolved error \(error)")
                fatalError("Unresolved error \(error)")
            }

            container.viewContext.automaticallyMergesChangesFromParent = true
        }

        return container
    }()

    public static let viewContext = persistentContainer.viewContext

    public static func createResultsController<T: NSFetchRequestResult>(_ fetchRequest: NSFetchRequest<T>,
                                                                        sectionNameKeyPath: String?) -> NSFetchedResultsController<T> {
        return NSFetchedResultsController<T>(fetchRequest: fetchRequest,
                                             managedObjectContext: self.persistentContainer.viewContext,
                                             sectionNameKeyPath: sectionNameKeyPath,
                                             cacheName: nil)
    }

    public static func clearCoreDataStorage() -> Future<Void, XikoloError> {
        return self.persistentContainer.managedObjectModel.entitiesByName.keys.filter { entityName in
            return entityName != "TrackingEvent"
        }.traverse { entityName in
            return self.clearCoreDataEntity(entityName)
        }.asVoid()
    }

    private static func clearCoreDataEntity(_ entityName: String) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        self.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            privateManagedObjectContext.shouldDeleteInaccessibleFaults = true
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs

            do {
                let result = try privateManagedObjectContext.execute(deleteRequest) as? NSBatchDeleteResult
                guard let objectIDArray = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSDeletedObjectsKey: objectIDArray]
                log.verbose("Try to delete all enities of \(entityName) (\(objectIDArray.count) enities)")
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                try privateManagedObjectContext.save()

                promise.success(())
            } catch {
                log.error("Failed to bulk delete all enities of \(entityName) - \(error)")
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

}
