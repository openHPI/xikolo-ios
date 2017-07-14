//
//  CourseDate+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 09.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData

extension CourseDate {

    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var date: Date?
    @NSManaged var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseDate> {
        return NSFetchRequest<CourseDate>(entityName: "CourseDate");
    }

}
