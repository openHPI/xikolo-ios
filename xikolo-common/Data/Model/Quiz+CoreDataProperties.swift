//
//  Quiz+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 25.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Quiz {

    @NSManaged var instructions: String?
    @NSManaged var lock_submissions_at: Date?
    @NSManaged var publish_results_at: Date?
    @NSManaged var show_welcome_page_int: NSNumber?
    @NSManaged var time_limit: NSNumber?
    @NSManaged var allowed_attempts: NSNumber?
    @NSManaged var max_points: NSDecimalNumber?
    @NSManaged var questions: Set<QuizQuestion>?

}
