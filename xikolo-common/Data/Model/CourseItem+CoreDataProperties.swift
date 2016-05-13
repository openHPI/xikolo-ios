//
//  CourseItem+CoreDataProperties.swift
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

extension CourseItem {

    @NSManaged var id: String?
    @NSManaged var content_type: String?
    @NSManaged var content_id: String?
    @NSManaged var title: String?
    @NSManaged var section: CourseSection?

}
