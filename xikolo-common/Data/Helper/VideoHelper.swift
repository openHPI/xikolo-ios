//
//  VideoHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 01.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation

class VideoHelper {

    @discardableResult static func sync(video: Video) -> Future<Video, XikoloError> {
        return VideoProvider.getVideo(video.id).flatMap { spineVideo -> Future<[Video], XikoloError> in
            return SpineModelHelper.syncObjectsFuture([video], spineObjects: [spineVideo], inject: nil, save: true)
        }.map { cdVideos in
            return cdVideos[0]
        }
    }

}
