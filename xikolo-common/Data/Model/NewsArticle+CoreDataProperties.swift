//
//  NewsArticle+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension NewsArticle {

    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var text: String?
    @NSManaged var published_at: Date?
    @NSManaged var visited_int: NSNumber?
    @NSManaged var course: Course?

}
