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

    class func syncObjects(_ objectsToUpdate: [BaseModel], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) throws -> [BaseModel] {
        var objectsToUpdate = objectsToUpdate
        let backgroundContext = CoreDataHelper.backgroundContext // do we need this? does it work?

        var cdObjects = [BaseModel]()
        if spineObjects.count > 0 {
            let model = type(of: spineObjects[0]).cdType
            let entityName = String(describing: model)
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: backgroundContext)!

            for spineObject in spineObjects {
                if let id = spineObject.id {
                    let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
                    request.predicate = predicate

                    var cdObject: BaseModel!
                    var results: [BaseModel]
                    results = try CoreDataHelper.executeFetchRequest(request);
                    
                    if (results.count > 0) {
                        cdObject = results[0]
                    } else {
                        cdObject = model.init(entity: entity, insertInto: backgroundContext)
                        cdObject.setValue(id, forKey: "id")
                    }
                    if spineObject.isLoaded {
                        CoreDataHelper.persistentContainer.performBackgroundLoadSpineAndWait(cdObject: cdObject, spineObject: spineObject, completion: { (inner: () throws -> Void) -> Void in
                            do {
                                try inner()
                            } catch let error {
                                fatalError("\(error)")
                            }
                        })
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
                }
            }
        }
        for object in objectsToUpdate {
            backgroundContext.delete(object)
        }
        if save {
            CoreDataHelper.saveContext()
        }
        return cdObjects
    }

    class func syncObjectsFuture(_ objectsToUpdateRequest: NSFetchRequest<NSFetchRequestResult>, spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) -> Future<[BaseModel], XikoloError> {
        return Future { complete in
            CoreDataHelper.persistentContainer.performBackgroundSyncAndWait(objectsToUpdateRequest, spineObjects: spineObjects, inject:inject, save: save, completion: { (inner: () throws -> [BaseModel]) -> Void in
                do {
                    let result = try inner()
                    complete(.success(result))
                } catch let error as XikoloError{
                    complete(.failure(error))
                } catch {
                    complete(.failure(XikoloError.unknownError(error)))
                }
            })
        }
    }

    class func syncObjectsFuture(_ objectsToUpdate: [BaseModel], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) -> Future<[BaseModel], XikoloError> {
        return Future { complete in
            CoreDataHelper.persistentContainer.performBackgroundSyncAndWait(objectsToUpdate, spineObjects: spineObjects, inject:inject, save: save, completion: { (inner: () throws -> [BaseModel]) -> Void in
                do {
                    let result = try inner()
                    complete(.success(result))
                } catch let error as XikoloError{
                    complete(.failure(error))
                } catch {
                    complete(.failure(XikoloError.unknownError(error)))
                }
            })
        }
    }

}
