//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension VideoHelper {

    struct FetchRequest {

        static func video(withId videoId: String) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", videoId)
            request.fetchLimit = 1
            return request
        }

    }

}
