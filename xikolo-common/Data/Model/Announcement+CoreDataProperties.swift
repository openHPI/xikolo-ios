//
//  Announcement+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData

extension Announcement {

    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var text: String?
    @NSManaged var published_at: Date?
    @NSManaged var visited_int: NSNumber?
    @NSManaged var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Announcement> {
        return NSFetchRequest<Announcement>(entityName: "Announcement");
    }

}
