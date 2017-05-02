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

    required override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    func notifyOnChange(_ observer: UIViewController, updatedHandler: @escaping (_ model: BaseModel) -> (), deletedHandler: @escaping () -> ()) {
        if baseModelObservers == nil {
            baseModelObservers = [:]
        }

        let baseModelObserver = BaseModelObserver(model: self, updatedHandler: updatedHandler, deletedHandler: deletedHandler)
        NotificationCenter.default.addObserver(baseModelObserver,
                                               selector: #selector(BaseModelObserver.dataModelDidChange),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.self.backgroundContext) // right?
        baseModelObservers[observer] = baseModelObserver
    }

    func removeNotifications(_ observer: UIViewController) {
        if let baseModelObserver = baseModelObservers[observer] {
            NotificationCenter.default.removeObserver(baseModelObserver)
            baseModelObservers.removeValue(forKey: observer)
        }
    }

}

extension BaseModel {

    func loadFromSpine(_ resource: BaseModelSpine) throws {
        for field in type(of: resource).fields {
            var value = resource.value(forKey: field.name)
            if value is NSNull {
                // This can happen, e.g. if a DateAttribute cannot be converted to NSDate.
                value = nil
            }
            if field is CompoundAttribute {
                if let value = value as? CompoundValue {
                    value.saveToCoreData(model: self)
                }
            } else if field is ToOneRelationship {
                if let value = value as? BaseModelSpine {
                    let currentRelatedObject = self.value(forKey: field.name) as? BaseModel
                    let relatedObjects = currentRelatedObject != nil ? [currentRelatedObject!] : [BaseModel]()
                    let cdObjects = try SpineModelHelper.syncObjects(relatedObjects, spineObjects: [value], inject: nil, save: false)
                    self.setValue(cdObjects[0], forKey: field.name)
                } else if let value = value as? Resource {
                    self.setValue(value, forKey: field.name)
                }
            } else if field is ToManyRelationship {
                if let value = value as? ResourceCollection {
                    let spineObjects = value.resources as! [BaseModelSpine]
                    let relatedObjects = self.value(forKey: field.name) as? [BaseModel] ?? []
                    let cdObjects = try SpineModelHelper.syncObjects(relatedObjects, spineObjects: spineObjects, inject: nil, save: false)
                    self.setValue(NSSet(array: cdObjects), forKey: field.name)
                }
            } else {
                self.setValue(value, forKey: field.name)
            }
        }
    }

    func loadFromDict(_ dict: [String: AnyObject?]) {
        for (key, value) in dict {
            self.setValue(value, forKey: key)
        }
    }

}

@objc class BaseModelObserver : NSObject {

    var model: BaseModel
    var updatedHandler: (_ model: BaseModel) -> ()
    var deletedHandler: () -> ()

    init(model: BaseModel, updatedHandler: @escaping (_ model: BaseModel) -> (), deletedHandler: @escaping () -> ()) {
        self.model = model
        self.updatedHandler = updatedHandler
        self.deletedHandler = deletedHandler
    }

    func dataModelDidChange(_ notification: Notification) {
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
                updatedHandler(model)
            }
        }
    }

}
