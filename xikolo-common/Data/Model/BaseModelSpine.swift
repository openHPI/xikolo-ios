//
//  BaseModelSpine.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Spine

class BaseModelSpine : Resource {
    
    class var cdType: BaseModel.Type {
        fatalError("Override cdType in a subclass.")
    }

}

class CompoundAttribute : Attribute {
}

class CompoundValue : NSObject {

    func saveToCoreData(model: BaseModel) {
        fatalError("Subclasses of CompoundValue need to implement saveToCoreData(model:).")
    }

}

@objc protocol EmbeddedObject : NSObjectProtocol {

    init(_ dict: [String: AnyObject])

    optional func toDict() -> [String: AnyObject]

}

class EmbeddedObjectAttribute : Attribute {

    let linkedType: EmbeddedObject.Type

    init(_ type: EmbeddedObject.Type) {
        linkedType = type
    }
    
}

struct EmbeddedObjectFormatter : ValueFormatter {

    func unformat(value: [String: AnyObject], attribute: EmbeddedObjectAttribute) -> AnyObject {
        let type = attribute.linkedType
        return type.init(value)
    }

    func format(value: AnyObject, attribute: EmbeddedObjectAttribute) -> AnyObject {
        guard let value = value as? EmbeddedObject else {
            return NSNull()
        }
        if let dict = value.toDict?() {
            return dict
        }
        return NSNull()
    }

}

class EmbeddedObjectsAttribute : Attribute {

    let linkedType: EmbeddedObject.Type

    init(_ type: EmbeddedObject.Type) {
        linkedType = type
    }

}

struct EmbeddedObjectsFormatter : ValueFormatter {

    func unformat(value: [[String: AnyObject]], attribute: EmbeddedObjectsAttribute) -> AnyObject {
        let type = attribute.linkedType
        return value.map { dict in type.init(dict) } as [AnyObject]
    }

    func format(value: [AnyObject], attribute: EmbeddedObjectsAttribute) -> AnyObject {
        // Implement in case we need it.
        return NSNull()
    }

}
