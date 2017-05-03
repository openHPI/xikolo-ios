//
//  SpineModelHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 06.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Result
import Spine

class SpineModelHelper {

    class func syncObjects(_ objectsToUpdateRequest: NSFetchRequest<NSFetchRequestResult>, spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) -> Future<[BaseModel], XikoloError> {
        return CoreDataHelper.executeFetchRequest(objectsToUpdateRequest).flatMap { objectsToUpdate -> Future<[BaseModel], XikoloError> in
            return syncObjects(objectsToUpdate, spineObjects: spineObjects, inject: inject, save: save)
        }
    }

    class func syncObjects(_ objectsToUpdate: [BaseModel], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) -> Future<[BaseModel], XikoloError> {
        var objectsToUpdate = objectsToUpdate
        let promise = Promise<[BaseModel], XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { (context) in
            var cdObjects = [BaseModel]()
            if spineObjects.count > 0 {
                let model = type(of: spineObjects[0]).cdType
                let entityName = String(describing: model)
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!

                for spineObject in spineObjects {
                    if let id = spineObject.id {
                        let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
                        request.predicate = predicate

                        CoreDataHelper.executeFetchRequest(request).onSuccess(callback: { (results) in
                            var cdObject: BaseModel!
                            if (results.count > 0) {
                                cdObject = results[0]
                            } else {
                                cdObject = model.init(entity: entity, insertInto: context)
                                cdObject.setValue(id, forKey: "id")
                            }
                            if spineObject.isLoaded {
                                cdObject.loadFromSpine(spineObject)
                            }
                            if let dict = inject {
                                cdObject.loadFromDict(dict)
                            }
                            if let sortableObject = cdObject as? DynamicSort {
                                sortableObject.computeOrder()
                            }
                            cdObjects.append(cdObject)
                            if let index = objectsToUpdate.index(of: cdObject) {
                                objectsToUpdate.remove(at: index)
                            }
                        }).onFailure(callback: { (xikoloError) in
                            promise.failure(xikoloError)
                        })
                    }
                }
            }
            for object in objectsToUpdate {
                context.delete(object)
            }
            if save {
                CoreDataHelper.saveContext(context)
            }

            return promise.success(cdObjects)
        }
        return promise.future
    }

}
