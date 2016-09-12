//
//  NewsArticleProvider.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation

class NewsArticleProvider {

    class func getNewsArticles() -> Future<[NewsArticleSpine], XikoloError> {
        return SpineHelper.findAll(NewsArticleSpine)
    }

}
