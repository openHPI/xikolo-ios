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

    @discardableResult static func refresh(richText: RichText) -> Future<RichText, XikoloError> {
        return RichTextProvider.getRichText(richText.id).flatMap { spineRichText -> Future<[BaseModel], XikoloError> in
            return SpineModelHelper.syncObjectsFuture([richText], spineObjects: [spineRichText], inject: nil, save: true)
        }.map { cdRichTexts in
            return cdRichTexts[0] as! RichText
        }
    }

    @discardableResult static func refresh(richTexts: [RichText]) -> Future<[RichText], XikoloError> {
        let richTextIds = richTexts.map { $0.id }
        return RichTextProvider.getRichTexts(richTextIds).flatMap { spineRichTexts -> Future<[BaseModel], XikoloError> in
            return SpineModelHelper.syncObjectsFuture(richTexts, spineObjects: spineRichTexts, inject: nil, save: true)
        }.map { cdRichTexts in
            return cdRichTexts as! [RichText]
        }
    }

}
