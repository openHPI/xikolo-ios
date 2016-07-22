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
        return RichTextProvider.getRichText(richText.id).flatMap { spineRichText -> Future<[BaseModel], XikoloError> in
            return SpineModelHelper.syncObjectsFuture([richText], spineObjects: [spineRichText], inject: nil, save: true)
        }.map { cdRichTexts in
            return cdRichTexts[0] as! RichText
        }
    }

}
