//
//  RichText.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class RichText : Content {

}

class RichTextSpine : BaseModelSpine {
    
    override class var cdType: BaseModel.Type {
        return RichText.self
    }
    
    override class var resourceType: ResourceType {
        return "rich-texts"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([:])
    }
    
}
