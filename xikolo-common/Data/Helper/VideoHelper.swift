//
//  VideoHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 01.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct VideoHelper {

    static func syncVideo(_ video: Video) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = VideoHelper.FetchRequest.video(withId: video.id)
        let query = SingleResourceQuery(resource: video)
        return SyncHelper.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
