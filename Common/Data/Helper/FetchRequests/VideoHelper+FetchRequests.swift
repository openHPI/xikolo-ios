//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension VideoHelper {

    public struct FetchRequest {

        static let hasDownloadedVideoPredicate = NSPredicate(format: "localFileBookmark != nil")
        static let hasDownloadedSlidesPredicate = NSPredicate(format: "localSlidesBookmark != nil")

        static func inCoursePredicate(withID id: String) -> NSPredicate {
            return NSPredicate(format: "item.section.course.id = %@", id)
        }

        static func video(withId videoId: String) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", videoId)
            request.fetchLimit = 1
            return request
        }

        public static func hasDownloadedVideo(inCourse courseID: String? = nil) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            if let id = courseID {
                let sectionSort = NSSortDescriptor(key: "item.section.position", ascending: true)
                let positionSort = NSSortDescriptor(key: "item.position", ascending: true)
                request.sortDescriptors = [sectionSort, positionSort]
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [hasDownloadedVideoPredicate, inCoursePredicate(withID: id)])
            } else {
                request.predicate = hasDownloadedVideoPredicate
            }

            return request
        }

        public static func hasDownloadedSlides(inCourse courseID: String? = nil) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            if let id = courseID {
                let sectionSort = NSSortDescriptor(key: "item.section.position", ascending: true)
                let positionSort = NSSortDescriptor(key: "item.position", ascending: true)
                request.sortDescriptors = [sectionSort, positionSort]
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [hasDownloadedSlidesPredicate, inCoursePredicate(withID: id)])
            } else {
                request.predicate = hasDownloadedSlidesPredicate
            }

            return request
        }

    }

}
