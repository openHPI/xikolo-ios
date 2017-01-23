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

    class func syncObjects(_ objectsToUpdateRequest: NSFetchRequest<NSFetchRequestResult>, spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) throws -> [BaseModel] {
        let objectsToUpdate = try CoreDataHelper.executeFetchRequest(objectsToUpdateRequest)
        return try syncObjects(objectsToUpdate, spineObjects: spineObjects, inject: inject, save: save)
    }

    class func syncObjects(_ objectsToUpdate: [BaseModel], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) throws -> [BaseModel] {
        var objectsToUpdate = objectsToUpdate

        var cdObjects = [BaseModel]()
        if spineObjects.count > 0 {
            let model = type(of: spineObjects[0]).cdType
            let entityName = String(describing: model)
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: CoreDataHelper.managedContext)!

            for spineObject in spineObjects {
                if let id = spineObject.id {
                    let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
                    request.predicate = predicate

                    var cdObject: BaseModel!

                    let results = try CoreDataHelper.executeFetchRequest(request)
                    if (results.count > 0) {
                        cdObject = results[0]
                    } else {
                        cdObject = model.init(entity: entity, insertInto: CoreDataHelper.managedContext)
                        cdObject.setValue(id, forKey: "id")
                    }
                    if spineObject.isLoaded {
                        try cdObject.loadFromSpine(spineObject)
                    }
                    if let dict = inject {
                        cdObject.loadFromDict(dict)
                    }
                    cdObjects.append(cdObject)
                    if let index = objectsToUpdate.index(of: cdObject) {
                        objectsToUpdate.remove(at: index)
                    }
                }
            }
        }
        for object in objectsToUpdate {
            CoreDataHelper.managedContext.delete(object)
        }
        if save {
            CoreDataHelper.saveContext()
        }
        return cdObjects
    }

    class func syncObjectsFuture(_ objectsToUpdateRequest: NSFetchRequest<NSFetchRequestResult>, spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) -> Future<[BaseModel], XikoloError> {
        return Future { complete in
            do {
                let cdItems = try syncObjects(objectsToUpdateRequest, spineObjects: spineObjects, inject:inject, save: save)
                complete(.success(cdItems))
            } catch let error as XikoloError {
                complete(.failure(error))
            } catch {
                complete(.failure(XikoloError.unknownError(error)))
            }
        }
    }

    class func syncObjectsFuture(_ objectsToUpdate: [BaseModel], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) -> Future<[BaseModel], XikoloError> {
        return Future { complete in
            do {
                let cdItems = try syncObjects(objectsToUpdate, spineObjects: spineObjects, inject:inject, save: save)
                complete(.success(cdItems))
            } catch let error as XikoloError {
                complete(.failure(error))
            } catch {
                complete(.failure(XikoloError.unknownError(error)))
            }
        }
    }

}
