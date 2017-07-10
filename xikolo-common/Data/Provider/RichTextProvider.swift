//
//  RichTextProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 10.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class RichTextProvider {

    class func getRichText(_ richTextId: String) -> Future<RichTextSpine, XikoloError> {
        return SpineHelper.findOne(richTextId, ofType: RichTextSpine.self)
    }

    class func getRichTexts(_ richTextIds: [String]) -> Future<[RichTextSpine], XikoloError> {
        let query = Query(resourceType: RichTextSpine.self, resourceIDs: richTextIds)
        return SpineHelper.find(query)
    }

}
