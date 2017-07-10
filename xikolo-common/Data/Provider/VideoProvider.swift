//
//  VideoProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 01.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class VideoProvider {

    class func getVideo(_ videoId: String) -> Future<VideoSpine, XikoloError> {
        return SpineHelper.findOne(videoId, ofType: VideoSpine.self)
    }

    class func getVideos(_ videoIds: [String]) -> Future<[VideoSpine], XikoloError> {
        let query = Query(resourceType: VideoSpine.self, resourceIDs: videoIds)
        return SpineHelper.find(query)
    }

}
