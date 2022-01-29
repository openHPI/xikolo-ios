//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Stockpile

public enum VideoHelper {

    @discardableResult static func syncVideo(_ video: Video) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.video(withId: video.id)
        let query = SingleResourceQuery(resource: video)
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

    @discardableResult public static func updateLastPosition(of video: Video, to lastPosition: Double) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.viewContext.perform {
            guard let video = CoreDataHelper.viewContext.existingTypedObject(with: video.objectID) as? Video else {
                promise.failure(XikoloError.coreDataObjectNotFound)
                return
            }

            video.lastPosition = lastPosition

            let saveResult = CoreDataHelper.viewContext.saveWithResult()
            promise.complete(saveResult)
        }

        return promise.future
    }

}
