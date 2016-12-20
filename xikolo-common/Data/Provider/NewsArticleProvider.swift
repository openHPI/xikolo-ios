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
        var query = Query(resourceType: NewsArticleSpine.self)
        query.filterOn("global", equalTo: "true")

        return SpineHelper.find(query)
    }

}
