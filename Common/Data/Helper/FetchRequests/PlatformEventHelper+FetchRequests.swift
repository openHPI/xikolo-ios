//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension PlatformEventHelper {

    enum FetchRequest {

        static var allPlatformEvents: NSFetchRequest<PlatformEvent> {
            let request: NSFetchRequest<PlatformEvent> = PlatformEvent.fetchRequest()
            let dateSort = NSSortDescriptor(keyPath: \PlatformEvent.createdAt, ascending: false)
            request.sortDescriptors = [dateSort]
            return request
        }

    }

}
