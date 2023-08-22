//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData

public class CoreDataHelper { // swiftlint:disable:this convenience_type

    public static var persistentContainer: NSPersistentContainer = {
        XikoloSecureUnarchiveFromDataTransformer.register()

        let bundle = Bundle(for: CoreDataHelper.self)
        let modelURL = bundle.url(forResource: "xikolo", withExtension: "momd").require()
        let model = NSManagedObjectModel(contentsOf: modelURL).require()
        let container = NSPersistentContainer(name: "xikolo", managedObjectModel: model)

        let mainBundle = Bundle.main.appGroupIdentifier!
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: mainBundle)!.appendingPathComponent("xikolodb")
        let sharedStoreDescription = NSPersistentStoreDescription(url: sharedStoreURL)

        var defaultStoreURL: URL?
        if let storeDescription = container.persistentStoreDescriptions.first, let url = storeDescription.url {
            defaultStoreURL = FileManager.default.fileExists(atPath: url.path) ? url : nil
        }

        if defaultStoreURL == nil {
            container.persistentStoreDescriptions = [sharedStoreDescription]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                logger.error("Persistent store load error", error: error)
                fatalError("Unresolved error \(error)")
            }

            container.viewContext.automaticallyMergesChangesFromParent = true

            // check if we need to migrate from default CoreData store location to the shared store location
            if let url = defaultStoreURL, url.absoluteString != sharedStoreURL.absoluteString {
                let coordinator = container.persistentStoreCoordinator
                if let oldStore = coordinator.persistentStore(for: url) {
                    do {
                        let options = [
                            NSMigratePersistentStoresAutomaticallyOption: true,
                            NSInferMappingModelAutomaticallyOption: true,
                        ]
                        try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, options: options, withType: NSSQLiteStoreType)
                    } catch {
                        print(error.localizedDescription)
                    }

                    // delete old CoreData store
                    let fileCoordinator = NSFileCoordinator(filePresenter: nil)
                    fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil) { url in
                        do {
                            try FileManager.default.removeItem(at: url)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
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
            return entityName != TrackingEvent.entity().name
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
                logger.info("Try to delete all entities of %@, %d entities", entityName, objectIDArray.count)
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                try privateManagedObjectContext.save()

                promise.success(())
            } catch {
                logger.error("Failed to bulk delete all entities of %@", entityName, error: error)
                ErrorManager.shared.report(error)
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

}
