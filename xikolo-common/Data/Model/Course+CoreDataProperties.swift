//
//  Course+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Course {

    @NSManaged var course_code: String?
    @NSManaged var course_description: String?
    @NSManaged var end_date: NSDate?
    @NSManaged var id: String
    @NSManaged var image_url: String?
    @NSManaged var is_enrolled_int: NSNumber?
    @NSManaged var language: String?
    @NSManaged var name: String?
    @NSManaged var start_date: NSDate?
    @NSManaged var teachers: String?
    @NSManaged var sections: NSSet?

}
