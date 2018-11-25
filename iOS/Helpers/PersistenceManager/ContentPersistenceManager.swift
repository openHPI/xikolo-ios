//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

protocol ContentPersistanceManager {

    func deleteDownloads(for course: Course)

}

extension StreamPersistenceManager: ContentPersistanceManager {

    func deleteDownloads(for course: Course) {
        course.sections.forEach { courseSection in
            self.deleteDownloads(for: courseSection)
        }
    }

}

extension SlidesPersistenceManager: ContentPersistanceManager {

    func deleteDownloads(for course: Course) {
        course.sections.forEach { courseSection in
            self.deleteDownloads(for: courseSection)
        }
    }

}

extension DocumentsPersistenceManager: ContentPersistanceManager {

    func deleteDownloads(for course: Course) {
        course.documents.forEach { document in
            self.deleteDownloads(for: document)
        }
    }

}
