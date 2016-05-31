//
//  SpineModelHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 06.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class SpineModelHelper {

    static private let appDelegate = UIApplication.sharedApplication().delegate as! AbstractAppDelegate
    static private let managedContext = appDelegate.managedObjectContext
    
    class func syncObjects(spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?) throws -> [BaseModel] {
        return try syncObjects(spineObjects, inject: inject, save: true)
    }

    class func syncObjects(spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) throws -> [BaseModel] {
        if spineObjects.count == 0 {
            return []
        }

        let model = spineObjects[0].dynamicType.cdType
        let entityName = String(model)
        let request = NSFetchRequest(entityName: entityName)
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)!

        var cdObjects = [BaseModel]()
        for spineObject in spineObjects {
            if let id = spineObject.id {
                let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
                request.predicate = predicate

                var cdObject: BaseModel!

                let results = try managedContext.executeFetchRequest(request) as! [BaseModel]
                if (results.count > 0) {
                    cdObject = results[0]
                } else {
                    cdObject = model.init(entity: entity, insertIntoManagedObjectContext: managedContext)
                    cdObject.setValue(id, forKey: "id")
                }
                try cdObject.loadFromSpine(spineObject)
                if let dict = inject {
                    cdObject.loadFromDict(dict)
                }
                cdObjects.append(cdObject)
            }
        }
        // TODO: Delete objects from CD that have not been returned
        if save {
            appDelegate.saveContext()
        }
        return cdObjects
    }

}
