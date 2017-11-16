//
//  VideoHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 01.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import BrightFutures

struct VideoHelper {

    static func syncVideo(_ video: Video) -> Future<Video, XikoloError> {
        let fetchRequest = VideoHelper.FetchRequest.video(withId: video.id)
        let query = SingleResourceQuery(resource: video)
        return SyncEngine.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

//    static func videoWith(id: String) -> Video? {
//        let request: NSFetchRequest<Video> = Video.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", id)
//        request.fetchLimit = 1
//        do {
//            let videos = try CoreDataHelper.executeFetchRequest(request)
//            return videos.first
//        } catch {
//            return nil
//        }
//    }

//    @discardableResult static func sync(video: Video) -> Future<Video, XikoloError> {
//        return VideoProvider.getVideo(video.id).flatMap { spineVideo -> Future<[Video], XikoloError> in
//            return SpineModelHelper.syncObjectsFuture([video], spineObjects: [spineVideo], inject: nil, save: true)
//        }.map { cdVideos in
//            return cdVideos[0]
//        }
//    }

}
