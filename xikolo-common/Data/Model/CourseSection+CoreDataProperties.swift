//
//  CourseSection+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CourseSection {

    @NSManaged var id: String
    @NSManaged var section_description: String?
    @NSManaged var title: String?
    @NSManaged var position: NSNumber?
    @NSManaged var course: Course?
    @NSManaged var items: NSSet?
    @NSManaged var accessible_int: NSNumber?
    @NSManaged var start_at: Date?
    @NSManaged var end_at: Date?

}
