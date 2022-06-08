//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData

enum EntityCreationHelper {

    static func newVideoItem(in context: NSManagedObjectContext, streamDownloaded: Bool = false) throws -> CourseItem {
        let courseItemEntityDescription = NSEntityDescription.entity(forEntityName: "CourseItem", in: context)!
        let videoEntityDescription = NSEntityDescription.entity(forEntityName: "Video", in: context)!

        let video = Video(entity: videoEntityDescription, insertInto: context)
        video.id = UUID().uuidString

        if streamDownloaded {
            let url = Bundle.main.url(forResource: "Info", withExtension: "plist")!
            let bookmarkData = try url.bookmarkData()
            video.localFileBookmark = NSData(data: bookmarkData)
        }

        let item = CourseItem(entity: courseItemEntityDescription, insertInto: context)
        item.id = UUID().uuidString
        item.content = video
        return item
    }
}
