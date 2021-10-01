//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension VideoHelper {

    public enum FetchRequest {

        private static let hasDownloadedStreamPredicate = NSPredicate(format: "localFileBookmark != nil")
        private static let hasDownloadedSlidesPredicate = NSPredicate(format: "localSlidesBookmark != nil")

        static func inCoursePredicate(_ course: Course) -> NSPredicate {
            return NSPredicate(format: "item.section.course = %@", course)
        }

        static func video(withId videoId: String) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", videoId)
            request.fetchLimit = 1
            return request
        }

        public static func videosWithDownloadedStream(in course: Course? = nil) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            if let course = course {
                let sectionSort = NSSortDescriptor(key: "item.section.position", ascending: true)
                let positionSort = NSSortDescriptor(key: "item.position", ascending: true)
                request.sortDescriptors = [sectionSort, positionSort]
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    self.hasDownloadedStreamPredicate,
                    self.inCoursePredicate(course),
                ])
            } else {
                request.predicate = self.hasDownloadedStreamPredicate
            }

            return request
        }

        public static func videosWithDownloadedSlides(in course: Course? = nil) -> NSFetchRequest<Video> {
            let request: NSFetchRequest<Video> = Video.fetchRequest()
            if let course = course {
                let sectionSort = NSSortDescriptor(key: "item.section.position", ascending: true)
                let positionSort = NSSortDescriptor(key: "item.position", ascending: true)
                request.sortDescriptors = [sectionSort, positionSort]
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    self.hasDownloadedSlidesPredicate,
                    self.inCoursePredicate(course),
                ])
            } else {
                request.predicate = self.hasDownloadedSlidesPredicate
            }

            return request
        }

    }

}
