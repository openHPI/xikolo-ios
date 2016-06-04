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

    class func getVideo(videoId: String) -> Future<VideoSpine, XikoloError> {
        let spine = Spine(baseURL: NSURL(string: Routes.API_V2_URL)!)
        spine.registerResource(VideoSpine)

        spine.registerValueFormatter(VideoStreamFormatter())
        spine.registerValueFormatter(DualStreamFormatter())

        return spine.findOne(videoId, ofType: VideoSpine.self).map { tuple in
            tuple.resource
        }.mapError { error in
            XikoloError.API(error)
        }
    }

}
