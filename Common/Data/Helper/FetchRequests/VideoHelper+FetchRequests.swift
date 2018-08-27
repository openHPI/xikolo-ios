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

        static func dowloadedVideos() -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            request.predicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [NSPredicate(format: "localFileBookmark != nil"),
                                               NSPredicate(format: "localSlidesBookmark != nil")]
            )
            return request
        }

    }

}
