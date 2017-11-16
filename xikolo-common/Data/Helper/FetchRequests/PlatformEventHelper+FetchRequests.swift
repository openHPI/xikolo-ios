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

        static var allPlatformEvents: NSFetchRequest<PlatformEvent> {
            let request: NSFetchRequest<PlatformEvent> = PlatformEvent.fetchRequest()
            let dateSort = NSSortDescriptor(key: "createdAt", ascending: false)
            request.sortDescriptors = [dateSort]
            return request
        }

    }

}
