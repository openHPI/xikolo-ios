//
//  CourseDate+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 09.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CourseDate {

    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var date: Date?
    @NSManaged var course: Course?

}
