//
//  PlatformEventHelper+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 16.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension PlatformEventHelper {

    struct FetchRequest {

        static func platformEvents(forCourse course: Course) -> NSFetchRequest<PlatformEvent> {
            let request: NSFetchRequest<PlatformEvent> = PlatformEvent.fetchRequest()
            let dateSort = NSSortDescriptor(key: "createdAt", ascending: false)
            request.sortDescriptors = [dateSort]
            request.predicate = NSPredicate(format: "course = %@", course)
            return request
        }

    }

}
