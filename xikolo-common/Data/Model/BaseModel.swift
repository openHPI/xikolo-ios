//
//  Base.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 28.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Spine
import UIKit

class BaseModel : NSManagedObject {

    var baseModelObservers: Dictionary<UIViewController, BaseModelObserver>!

    required override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    func notifyOnChange(observer: UIViewController, updatedHandler: (model: BaseModel) -> (), deletedHandler: () -> ()) {
        if baseModelObservers == nil {
            baseModelObservers = [:]
        }

        let appDelegate = UIApplication.sharedApplication().delegate as! AbstractAppDelegate
        let managedContext = appDelegate.managedObjectContext

        let baseModelObserver = BaseModelObserver(model: self, updatedHandler: updatedHandler, deletedHandler: deletedHandler)
        NSNotificationCenter.defaultCenter().addObserver(baseModelObserver, selector: #selector(BaseModelObserver.dataModelDidChange), name: NSManagedObjectContextObjectsDidChangeNotification, object: managedContext)
        baseModelObservers[observer] = baseModelObserver
    }

    func removeNotifications(observer: UIViewController) {
        if let baseModelObserver = baseModelObservers[observer] {
            NSNotificationCenter.defaultCenter().removeObserver(baseModelObserver)
            baseModelObservers.removeValueForKey(observer)
        }
    }

}

extension BaseModel {

    func loadFromSpine(resource: BaseModelSpine) throws {
        for field in resource.dynamicType.fields {
            let value = resource.valueForKey(field.name)
            if field is Relationship {
                if let value = value as? BaseModelSpine {
                    let cdObjects = try SpineModelHelper.syncObjects([value], inject: nil, save: false)
                    self.setValue(cdObjects[0], forKey: field.name)
                }
            } else {
                self.setValue(value, forKey: field.name)
            }
        }
    }

    func loadFromDict(dict: [String: AnyObject?]) {
        for (key, value) in dict {
            self.setValue(value, forKey: key)
        }
    }

}

@objc class BaseModelObserver : NSObject {

    var model: BaseModel
    var updatedHandler: (model: BaseModel) -> ()
    var deletedHandler: () -> ()

    init(model: BaseModel, updatedHandler: (model: BaseModel) -> (), deletedHandler: () -> ()) {
        self.model = model
        self.updatedHandler = updatedHandler
        self.deletedHandler = deletedHandler
    }

    func dataModelDidChange(notification: NSNotification) {
        let updatedObjects = notification.userInfo![NSUpdatedObjectsKey]
        let deletedObjects = notification.userInfo![NSDeletedObjectsKey]

        if let deletedObjects = deletedObjects as? Set<NSManagedObject> {
            if deletedObjects.contains(model) {
                deletedHandler()
                return
            }
        }
        if let updatedObjects = updatedObjects as? Set<NSManagedObject> {
            if updatedObjects.contains(model) {
                updatedHandler(model: model)
            }
        }
    }

}
