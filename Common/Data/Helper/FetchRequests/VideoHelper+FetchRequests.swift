//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension VideoHelper {

    public enum FetchRequest {

        private static let hasDownloadedStreamPredicate = NSPredicate(format: "localFileBookmark != nil")
        private static let hasDownloadedSlidesPredicate = NSPredicate(format: "localSlidesBookmark != nil")

        static func inCoursePredicate(withID id: String) -> NSPredicate {
            return NSPredicate(format: "item.section.course.id = %@", id)
        }

        static func video(withId videoId: String) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", videoId)
            request.fetchLimit = 1
            return request
        }

        public static func videosWithDownloadedStream(inCourse courseID: String? = nil) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            if let id = courseID {
                let sectionSort = NSSortDescriptor(key: "item.section.position", ascending: true)
                let positionSort = NSSortDescriptor(key: "item.position", ascending: true)
                request.sortDescriptors = [sectionSort, positionSort]
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    self.hasDownloadedStreamPredicate,
                    self.inCoursePredicate(withID: id),
                ])
            } else {
                request.predicate = self.hasDownloadedStreamPredicate
            }

            return request
        }

        public static func videosWithDownloadedSlides(inCourse courseID: String? = nil) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            if let id = courseID {
                let sectionSort = NSSortDescriptor(key: "item.section.position", ascending: true)
                let positionSort = NSSortDescriptor(key: "item.position", ascending: true)
                request.sortDescriptors = [sectionSort, positionSort]
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    self.hasDownloadedSlidesPredicate,
                    self.inCoursePredicate(withID: id),
                ])
            } else {
                request.predicate = self.hasDownloadedSlidesPredicate
            }

            return request
        }

    }

}
