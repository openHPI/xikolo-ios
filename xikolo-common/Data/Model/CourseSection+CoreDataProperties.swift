//
//  CourseSection+CoreDataProperties.swift
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

extension CourseSection {

    @NSManaged var id: String
    @NSManaged var section_description: String?
    @NSManaged var title: String?
    @NSManaged var course: Course?
    @NSManaged var items: NSSet?

}
