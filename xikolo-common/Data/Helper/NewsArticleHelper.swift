//
//  NewsArticleHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Result

class NewsArticleHelper {

    static private let entity = NSEntityDescription.entityForName("NewsArticle", inManagedObjectContext: CoreDataHelper.managedContext)!

    static func getRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "NewsArticle")
        let dateSort = NSSortDescriptor(key: "published_at", ascending: false)
        request.sortDescriptors = [dateSort]
        return request
    }

    static func syncNewsArticles() -> Future<[NewsArticle], XikoloError> {
        return NewsArticleProvider.getNewsArticles().flatMap { spineNewsArticles -> Future<[BaseModel], XikoloError> in
            let request = getRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineNewsArticles, inject: nil, save: true)
        }.map { cdNewsArticles in
            return cdNewsArticles as! [NewsArticle]
        }
    }

}
