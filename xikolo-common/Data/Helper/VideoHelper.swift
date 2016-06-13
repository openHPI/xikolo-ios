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

    static func syncVideo(video: Video) -> Future<Video, XikoloError> {
        return VideoProvider.getVideo(video.id).flatMap { videoSpine in
            future(context: ImmediateExecutionContext) {
                do {
                    try SpineModelHelper.syncObjects([videoSpine], inject: nil)
                    return Result.Success(video)
                } catch let error as XikoloError {
                    return Result.Failure(error)
                } catch {
                    return Result.Failure(XikoloError.UnknownError(error))
                }
            }
        }
    }

}
