//
//  NewsArticleProvider.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class NewsArticleProvider {

    class func getNewsArticles() -> Future<[NewsArticleSpine], XikoloError> {
        let spine = SpineModelHelper.createSpineClient()
        spine.registerResource(NewsArticleSpine)

        return spine.findAll(NewsArticleSpine).map { tuple in
            tuple.resources.map { $0 as! NewsArticleSpine }
        }.mapError { error in
            XikoloError.API(error)
        }
    }
    
}
