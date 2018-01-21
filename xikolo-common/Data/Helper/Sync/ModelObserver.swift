//
//  ModelObserver.swift
//  xikolo-ios
//
//  Created by Max Bothe on 27.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension NSManagedObject {

    func notifyOnChange(_ observer: UIViewController,
                        updateHandler: @escaping ModelObserver.UpdateHandler,
                        deleteHandler: @escaping ModelObserver.DeleteHandler) {
        ModelObserverManager.shared.notifyOnChange(forObject: self, forObserver: observer, updateHandler: updateHandler, deleteHandler: deleteHandler)
    }

    func removeNotifications(_ observer: UIViewController) {
        ModelObserverManager.shared.removeNotifications(forObject: self, forObserver: observer)
    }

}

class ModelObserverManager {

    static let shared = ModelObserverManager()

    struct ModelObeserverKey: Hashable {
        let viewController: UIViewController
        let objectId: NSManagedObjectID

        var hashValue: Int {
            return self.viewController.hashValue ^ self.objectId.hashValue
        }

        static func ==(lhs: ModelObserverManager.ModelObeserverKey, rhs: ModelObserverManager.ModelObeserverKey) -> Bool {
            return lhs.viewController == rhs.viewController && lhs.objectId == rhs.objectId
        }
    }

    private var modelObservers: [ModelObeserverKey: ModelObserver] = [:]

    func notifyOnChange(forObject object: NSManagedObject,
                        forObserver observer: UIViewController,
                        updateHandler: @escaping ModelObserver.UpdateHandler,
                        deleteHandler: @escaping ModelObserver.DeleteHandler) {
        let key = ModelObeserverKey(viewController: observer, objectId: object.objectID)
        let modelObserver = ModelObserver(model: object, updateHandler: updateHandler, deleteHandler: deleteHandler)
        NotificationCenter.default.addObserver(modelObserver,
                                               selector: #selector(ModelObserver.dataModelDidChange),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: object.managedObjectContext ?? CoreDataHelper.viewContext)
        self.modelObservers[key] = modelObserver
    }

    func removeNotifications(forObject object: NSManagedObject, forObserver observer: UIViewController) {
        let key = ModelObeserverKey(viewController: observer, objectId: object.objectID)
        if let modelObserver = self.modelObservers[key] {
            NotificationCenter.default.removeObserver(modelObserver)
            self.modelObservers.removeValue(forKey: key)
        }
    }
}

class ModelObserver {

    typealias UpdateHandler = () -> ()
    typealias DeleteHandler = () -> ()

    var model: NSManagedObject
    var updateHandler: UpdateHandler
    var deleteHandler: DeleteHandler

    init(model: NSManagedObject, updateHandler: @escaping UpdateHandler, deleteHandler: @escaping DeleteHandler) {
        self.model = model
        self.updateHandler = updateHandler
        self.deleteHandler = deleteHandler
    }

    @objc func dataModelDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            log.debug("No user info provided in notification")
            return
        }

        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updatedObjects.contains(self.model) {
            self.updateHandler()
        } else if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletedObjects.contains(self.model) {
            self.deleteHandler()
        }
    }

}
