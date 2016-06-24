//
//  SpineModelHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 06.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation

class SpineModelHelper {

    class func syncObjects(objectsToUpdateRequest: NSFetchRequest, spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) throws -> [BaseModel] {
        let objectsToUpdate = try CoreDataHelper.executeFetchRequest(objectsToUpdateRequest)
        return try syncObjects(objectsToUpdate, spineObjects: spineObjects, inject: inject, save: save)
    }

    class func syncObjects(objectsToUpdate: [BaseModel], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) throws -> [BaseModel] {
        var objectsToUpdate = objectsToUpdate

        var cdObjects = [BaseModel]()
        if spineObjects.count > 0 {
            let model = spineObjects[0].dynamicType.cdType
            let entityName = String(model)
            let request = NSFetchRequest(entityName: entityName)
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: CoreDataHelper.managedContext)!

            for spineObject in spineObjects {
                if let id = spineObject.id {
                    let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
                    request.predicate = predicate

                    var cdObject: BaseModel!

                    let results = try CoreDataHelper.executeFetchRequest(request)
                    if (results.count > 0) {
                        cdObject = results[0]
                    } else {
                        cdObject = model.init(entity: entity, insertIntoManagedObjectContext: CoreDataHelper.managedContext)
                        cdObject.setValue(id, forKey: "id")
                    }
                    try cdObject.loadFromSpine(spineObject)
                    if let dict = inject {
                        cdObject.loadFromDict(dict)
                    }
                    cdObjects.append(cdObject)
                    if let index = objectsToUpdate.indexOf(cdObject) {
                        objectsToUpdate.removeAtIndex(index)
                    }
                }
            }
        }
        for object in objectsToUpdate {
            CoreDataHelper.managedContext.deleteObject(object)
        }
        if save {
            CoreDataHelper.saveContext()
        }
        return cdObjects
    }

}
