//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Stockpile

public enum DocumentHelper {

    public static func syncDocuments(forCourse course: Course) -> Future<Void, XikoloError> {
        let courseObjectId = course.objectID

        let fetchRequest = Self.FetchRequest.documents(forCourse: course)
        var query = MultipleResourcesQuery(type: Document.self)
        query.addFilter(forKey: "course", withValue: course.id)
        query.include("localizations")

        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest,
                                              withQuery: query,
                                              deleteNotExistingResources: false).flatMap { syncResult -> Future<Void, XikoloError> in
            let promise = Promise<Void, XikoloError>()

            CoreDataHelper.persistentContainer.performBackgroundTask { context in
                let course = context.typedObject(with: courseObjectId) as Course

                for documentObjectId in syncResult.objectIds {
                    let document = context.typedObject(with: documentObjectId) as Document
                    document.courses.insert(course)

                    // Re-setting the document of all localization to notify the NSFetchedResultController about the changes
                    for localization in document.localizations {
                        localization.document = document
                    }
                }

                promise.complete(context.saveWithResult())
            }

            return promise.future
        }
    }

}
