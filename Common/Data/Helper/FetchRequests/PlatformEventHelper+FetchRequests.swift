//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
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
