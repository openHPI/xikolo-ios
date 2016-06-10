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

    class func getRichText(richTextId: String) -> Future<RichTextSpine, XikoloError> {
        let spine = Spine(baseURL: NSURL(string: Routes.API_V2_URL)!)
        spine.registerResource(RichTextSpine)

        return spine.findOne(richTextId, ofType: RichTextSpine.self).map { tuple in
            tuple.resource
        }.mapError { error in
            XikoloError.API(error)
        }
    }
    
}
