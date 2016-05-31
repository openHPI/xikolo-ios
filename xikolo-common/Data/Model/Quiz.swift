//
//  Quiz.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class Quiz : Content {

}

class QuizSpine : BaseModelSpine {
    
    override class var cdType: BaseModel.Type {
        return Quiz.self
    }
    
    override class var resourceType: ResourceType {
        return "quizzes"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([:])
    }
    
}
