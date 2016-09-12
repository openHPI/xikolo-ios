//
//  RichTextProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 10.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation

class RichTextProvider {

    class func getRichText(richTextId: String) -> Future<RichTextSpine, XikoloError> {
        return SpineHelper.findOne(richTextId, ofType: RichTextSpine.self)
    }

}
