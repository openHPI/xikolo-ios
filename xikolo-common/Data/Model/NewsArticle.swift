//
//  NewsArticle.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class NewsArticle : BaseModel {

}

class NewsArticleSpine : BaseModelSpine {

    var title: String?
    var text: String?
    var published_at: NSDate?
    var visited: NSNumber?

    override class var cdType: BaseModel.Type {
        return NewsArticle.self
    }

    override class var resourceType: ResourceType {
        return "news-articles"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute(),
            "text": Attribute(),
            "published_at": DateAttribute(),
            "visited": Attribute(),
            ])
    }
    
}
