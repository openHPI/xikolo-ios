//
//  QuizQuestion+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 28.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension QuizQuestion {

    @NSManaged var explanation: String?
    @NSManaged var id: String
    @NSManaged var max_points: NSDecimalNumber?
    @NSManaged var shuffle_answers_int: NSNumber?
    @NSManaged var text: String?
    @NSManaged var type: String?
    @NSManaged var quiz: Quiz?

}
