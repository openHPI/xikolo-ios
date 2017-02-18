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

    var visited: Bool? {
        get {
            return visited_int?.boolValue
        }
        set(new_has_visited) {
            visited_int = new_has_visited as NSNumber?
        }
    }


}

class NewsArticleSpine : BaseModelSpine {

    var title: String?
    var text: String?
    var published_at: Date?
    var visited_int: NSNumber?

    var course: CourseSpine?

    //used for PATCH
    convenience init(newsItem: NewsArticle){
        self.init()
        self.id = newsItem.id
        self.visited_int = newsItem.visited_int
    }
    
    override class var cdType: BaseModel.Type {
        return NewsArticle.self
    }

    override class var resourceType: ResourceType {
        return "news-articles"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute().readOnly(),
            "text": Attribute().readOnly(),
            "published_at": DateAttribute().readOnly(),
            "visited_int": Attribute().serializeAs("visited"),
            "course": ToOneRelationship(CourseSpine.self).readOnly(),
        ])
    }
    
}
