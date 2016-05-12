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

    class func syncObjects(model: BaseModel.Type, spineObjects: [Resource], inject: [String: AnyObject?]?) throws {
        let entityName = String(model)
        let request = NSFetchRequest(entityName: entityName)
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)!

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
                cdObject.loadFromSpine(spineObject)
                if let dict = inject {
                    cdObject.loadFromDict(dict)
                }
            }
        }
        // TODO: Delete objects from CD that have not been returned
        appDelegate.saveContext()
    }

}
