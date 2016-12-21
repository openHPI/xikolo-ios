//
//  PlatformEvent+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 07.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PlatformEvent {

    @NSManaged var created_at: NSDate?
    @NSManaged var preview: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var id: String
    @NSManaged var course: Course?

}
