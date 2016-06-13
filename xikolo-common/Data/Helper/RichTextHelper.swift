//
//  RichTextHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 10.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Result

class RichTextHelper {

    static func refreshRichText(richText: RichText) -> Future<RichText, XikoloError> {
        return RichTextProvider.getRichText(richText.id).flatMap { richTextSpine in
            future(context: ImmediateExecutionContext) {
                do {
                    try SpineModelHelper.syncObjects([richText], spineObjects: [richTextSpine], inject: nil, save: true)
                    return Result.Success(richText)
                } catch let error as XikoloError {
                    return Result.Failure(error)
                } catch {
                    return Result.Failure(XikoloError.UnknownError(error))
                }
            }
        }
    }
    
}
