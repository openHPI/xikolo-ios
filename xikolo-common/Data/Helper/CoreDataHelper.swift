//
//  CoreDataHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 02.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CoreDataHelper {

    static let appDelegate = UIApplication.sharedApplication().delegate as! AbstractAppDelegate
    static let managedContext = appDelegate.managedObjectContext

    static func executeFetchRequest(request: NSFetchRequest) throws -> [BaseModel] {
        do {
            return try managedContext.executeFetchRequest(request) as! [BaseModel]
        } catch let error as NSError {
            throw XikoloError.CoreData(error)
        }
    }

}
