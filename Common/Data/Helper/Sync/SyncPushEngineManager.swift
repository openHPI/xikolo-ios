//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import SyncEngine

public class SyncPushEngineManager {

    private let persistentContainerQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    let syncEngine: XikoloSyncEngine
    private var pushEngines: [SyncPushEngine] = []

    public init(syncEngine: XikoloSyncEngine) {
        self.syncEngine = syncEngine
    }

    public func startObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(note:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    public func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.viewContext)
    }

    public func register<Resource>(_ newType: Resource.Type) where Resource: NSManagedObject & Pushable {
        let pushEngine = SyncPushEnginePush(type: Resource.self, manager: self)
        self.pushEngines.append(pushEngine)
    }

    public func register<Resource>(_ newType: Resource.Type) where Resource: NSManagedObject & Pushable & Pullable {
        let pushEngine = SyncPushEnginePushPull(type: Resource.self, manager: self)
        self.pushEngines.append(pushEngine)
    }

    @objc private func coreDataChange(note: Notification) {
        let shouldCheckForChangesToPush = [NSUpdatedObjectsKey, NSInsertedObjectsKey, NSRefreshedObjectsKey].map { key in
            guard let objects = note.userInfo?[key] as? Set<NSManagedObject>, !objects.isEmpty else { return false }
            return objects.contains { $0 is Pushable }
        }.contains(true)

        if shouldCheckForChangesToPush {
            self.pushEngines.forEach { $0.check() }
        }

    }

    func addOperation(_ block: @escaping () -> Void) {
        self.persistentContainerQueue.addOperation(block)
    }

}
