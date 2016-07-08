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
        return NewsArticleProvider.getNewsArticles().flatMap { spineItems in
            future(context: ImmediateExecutionContext) {
                do {
                    let request = getRequest()
                    let cdItems = try SpineModelHelper.syncObjects(request, spineObjects: spineItems, inject: nil, save: true)
                    return Result.Success(cdItems as! [NewsArticle])
                } catch let error as XikoloError {
                    return Result.Failure(error)
                } catch {
                    return Result.Failure(XikoloError.UnknownError(error))
                }
            }
        }
    }
    
}
