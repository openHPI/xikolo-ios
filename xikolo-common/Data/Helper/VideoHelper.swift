//
//  VideoHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 01.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Result

class VideoHelper {

    static func syncVideo(video: Video) -> Future<Video, NSError> {
        if let id = video.id {
            let future1: Future<VideoSpine, NSError> = VideoProvider.getVideo(id).mapError { error in
                return error as NSError
            }
            return future1.flatMap{ videoSpine in
                future {
                    do {
                        try SpineModelHelper.syncObjects([videoSpine], inject: nil)
                        return Result<Video, NSError>.Success(video)
                    } catch let error as NSError {
                        return Result<Video, NSError>.Failure(error)
                    }
                }
            }
        }
        let failedPromise = Promise<Video, NSError>()
        failedPromise.failure(NSError(domain: "de.xikolo", code: 2, userInfo: [:]))
        return failedPromise.future
    }

}
