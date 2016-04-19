//
//  CourseCDModel+CoreDataProperties.swift
//  
//
//  Created by Jonas Müller on 07.10.15.
//
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension CourseCDModel {

    @NSManaged var course_code: String?
    @NSManaged var course_description: String?
    @NSManaged var id: String?
    @NSManaged var is_enrolled: NSNumber?
    @NSManaged var language: String?
    @NSManaged var lecturer: String?
    @NSManaged var locked: NSNumber?
    @NSManaged var name: String?
    @NSManaged var visual_url: String?

}
