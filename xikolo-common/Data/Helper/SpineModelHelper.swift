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

    class func createSpineClient() -> Spine {
        #if DEBUG
            Spine.setLogLevel(.Debug, forDomain: .Networking)
            Spine.setLogLevel(.Debug, forDomain: .Serializing)
            Spine.setLogLevel(.Debug, forDomain: .Spine)
        #endif

        let spine = Spine(baseURL: NSURL(string: Routes.API_V2_URL)!)
        let httpClient = spine.networkClient as! HTTPClient

        NetworkHelper.getRequestHeaders().forEach { key, value in
            httpClient.setHeader(key, to: value)
        }

        spine.registerValueFormatter(EmbeddedObjectsFormatter())

        return spine
    }

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

    class func syncObjectsFuture(objectsToUpdateRequest: NSFetchRequest, spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) -> Future<[BaseModel], XikoloError> {
        return future(context: ImmediateExecutionContext) {
            do {
                let cdItems = try syncObjects(objectsToUpdateRequest, spineObjects: spineObjects, inject:inject, save: save)
                return Result.Success(cdItems)
            } catch let error as XikoloError {
                return Result.Failure(error)
            } catch {
                return Result.Failure(XikoloError.UnknownError(error))
            }
        }
    }

    class func syncObjectsFuture(objectsToUpdate: [BaseModel], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) -> Future<[BaseModel], XikoloError> {
        return future(context: ImmediateExecutionContext) {
            do {
                let cdItems = try syncObjects(objectsToUpdate, spineObjects: spineObjects, inject:inject, save: save)
                return Result.Success(cdItems)
            } catch let error as XikoloError {
                return Result.Failure(error)
            } catch {
                return Result.Failure(XikoloError.UnknownError(error))
            }
        }
    }

}
