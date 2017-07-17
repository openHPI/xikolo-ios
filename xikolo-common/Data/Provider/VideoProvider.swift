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

}
