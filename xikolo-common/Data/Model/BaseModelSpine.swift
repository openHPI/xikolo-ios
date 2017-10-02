//
//  BaseModelSpine.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Spine

@objcMembers
class BaseModelSpine : Resource {
    
    class var cdType: BaseModel.Type {
        fatalError("Override cdType in a subclass.")
    }

}

@objcMembers
class CompoundAttribute : Attribute {
}

@objcMembers
class CompoundValue : NSObject {

    func saveToCoreData(model: BaseModel) {
        fatalError("Subclasses of CompoundValue need to implement saveToCoreData(model:).")
    }

}

@objc protocol EmbeddedObject : NSObjectProtocol {

    init(_ dict: [String: AnyObject])

    @objc optional func toDict() -> [String: AnyObject]

}

@objcMembers
class EmbeddedObjectAttribute : Attribute {

    let linkedType: EmbeddedObject.Type

    init(_ type: EmbeddedObject.Type) {
        linkedType = type
    }
    
}

struct EmbeddedObjectFormatter : ValueFormatter {
    typealias FormattedType = [String: AnyObject]
    typealias UnformattedType = AnyObject
    typealias AttributeType = EmbeddedObjectAttribute

    func unformatValue(_ value: FormattedType, forAttribute: AttributeType) -> UnformattedType {
        let type = forAttribute.linkedType
        return type.init(value)
    }

    func formatValue(_ value: UnformattedType, forAttribute: AttributeType) -> FormattedType {
        guard let value = value as? EmbeddedObject else {
            return [:]
        }
        if let dict = value.toDict?() {
            return dict
        }
        return [:]
    }

}

class EmbeddedObjectsAttribute : Attribute {

    let linkedType: EmbeddedObject.Type

    init(_ type: EmbeddedObject.Type) {
        linkedType = type
    }

}

struct EmbeddedObjectsFormatter : ValueFormatter {
    typealias FormattedType = [[String: AnyObject]]
    typealias UnformattedType = [AnyObject]
    typealias AttributeType = EmbeddedObjectsAttribute

    func unformatValue(_ value: FormattedType, forAttribute: AttributeType) -> UnformattedType {
        let type = forAttribute.linkedType
        return value.map { dict in type.init(dict) } as [AnyObject]
    }

    func formatValue(_ value: UnformattedType, forAttribute: AttributeType) -> FormattedType {
        // Implement in case we need it.
        return []
    }

}

@objc protocol EmbeddedDictObject : NSObjectProtocol {

    var key: String? { get }

    init?(key: String, data: AnyObject)

    @objc optional func data() -> AnyObject

}

@objcMembers
class EmbeddedDictAttribute : Attribute {

    let linkedType: EmbeddedDictObject.Type

    init(_ type: EmbeddedDictObject.Type) {
        linkedType = type
    }

}

struct EmbeddedDictFormatter : ValueFormatter {
    typealias FormattedType = [String: AnyObject]
    typealias UnformattedType = [String: EmbeddedDictObject]
    typealias AttributeType = EmbeddedDictAttribute

    func unformatValue(_ value: FormattedType, forAttribute: AttributeType) -> UnformattedType {
        let type = forAttribute.linkedType
        var out = [String: EmbeddedDictObject]()
        value.forEach { (key, value) in
            if let obj = type.init(key: key, data: value) {
                out[key] = obj
            }
        }
        return out
    }

    func formatValue(_ value: UnformattedType, forAttribute: AttributeType) -> FormattedType {
        var out = [String: AnyObject]()
        for (_, obj) in value {
            if let key = obj.key, let data = obj.data?() {
                out[key] = data
            }
        }
        return out
    }

}
