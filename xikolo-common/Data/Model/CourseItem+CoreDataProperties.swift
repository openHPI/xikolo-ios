//
//  CourseItem+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData

extension CourseItem {

    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var visited_int: NSNumber?
    @NSManaged var proctored_int: NSNumber?
    @NSManaged var position: NSNumber?
    @NSManaged var accessible_int: NSNumber?
    @NSManaged var content: Content?
    @NSManaged var section: CourseSection?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseItem> {
        return NSFetchRequest<CourseItem>(entityName: "CourseItem");
    }

}
