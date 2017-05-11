//
//  CourseItem+CoreDataProperties.swift
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

extension CourseItem {

    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var visited_int: NSNumber?
    @NSManaged var proctored_int: NSNumber?
    @NSManaged var position: NSNumber?
    @NSManaged var content: Content?
    @NSManaged var section: CourseSection?

}
