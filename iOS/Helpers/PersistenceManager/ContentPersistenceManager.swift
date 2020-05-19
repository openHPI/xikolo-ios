//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

protocol ContentPersistenceManager {

    func deleteDownloads(for course: Course)

}

extension StreamPersistenceManager: ContentPersistenceManager {

    func deleteDownloads(for course: Course) {
        course.sections.forEach { courseSection in
            self.deleteDownloads(for: courseSection)
        }
    }

}

extension SlidesPersistenceManager: ContentPersistenceManager {

    func deleteDownloads(for course: Course) {
        course.sections.forEach { courseSection in
            self.deleteDownloads(for: courseSection)
        }
    }

}

extension DocumentsPersistenceManager: ContentPersistenceManager {

    func deleteDownloads(for course: Course) {
        course.documents.forEach { document in
            self.deleteDownloads(for: document)
        }
    }

}
