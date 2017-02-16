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

        let baseModelObserver = BaseModelObserver(model: self, updatedHandler: updatedHandler, deletedHandler: deletedHandler)
        NSNotificationCenter.defaultCenter().addObserver(baseModelObserver, selector: #selector(BaseModelObserver.dataModelDidChange), name: NSManagedObjectContextObjectsDidChangeNotification, object: CoreDataHelper.managedContext)
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
            var value = resource.valueForKey(field.name)
            if value is NSNull {
                // This can happen, e.g. if a DateAttribute cannot be converted to NSDate.
                value = nil
            }
            if field is CompoundAttribute {
                if let value = value as? CompoundValue {
                    value.saveToCoreData(self)
                }
            } else if field is ToOneRelationship {
                if let value = value as? BaseModelSpine {
                    let currentRelatedObject = self.valueForKey(field.name) as? BaseModel
                    let relatedObjects = currentRelatedObject != nil ? [currentRelatedObject!] : [BaseModel]()
                    let cdObjects = try SpineModelHelper.syncObjects(relatedObjects, spineObjects: [value], inject: nil, save: false)
                    self.setValue(cdObjects[0], forKey: field.name)
                } else if let value = value as? Resource {
                    self.setValue(value, forKey: field.name)
                }
            } else if field is ToManyRelationship {
                if let value = value as? ResourceCollection {
                    let spineObjects = value.resources as! [BaseModelSpine]
                    let relatedObjects = self.valueForKey(field.name) as? [BaseModel] ?? []
                    let cdObjects = try SpineModelHelper.syncObjects(relatedObjects, spineObjects: spineObjects, inject: nil, save: false)
                    self.setValue(NSSet(array: cdObjects), forKey: field.name)
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
