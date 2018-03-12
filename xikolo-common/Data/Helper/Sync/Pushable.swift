//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Result

enum ObjectState: Int16 {
    case unchanged = 0
    case new
    case modified
    case deleted
}

protocol IncludedPushable {
    func resourceAttributes() -> [String: Any]
}

protocol Pushable: ResourceTypeRepresentable, IncludedPushable, NSFetchRequestResult {
    var objectState: ObjectState { get }

    static func resourceDataObject(attributes: [String: Any], relationships: [String: AnyObject]?) -> [String: Any]
    static func resourceData(attributes: [String: Any], relationships: [String: AnyObject]?) -> Result<Data, XikoloError>
    func resourceData() -> Result<Data, XikoloError>
    func resourceRelationships() -> [String: AnyObject]?
    func markAsUnchanged()
}

extension Pushable {

    static func resourceDataObject(attributes: [String: Any], relationships: [String: AnyObject]?) -> [String: Any] {
        var data: [String: Any] = [ "type": Self.type ]

        data["attributes"] = attributes
        if let resourceRelationships = relationships {
            var relationships: [String: Any] = [:]
            for (relationshipName, object) in resourceRelationships {
                if let resource = object as? ResourceRepresentable {
                    relationships[relationshipName] = ["data": resource.identifier]
                } else if let resources = object as? [ResourceRepresentable] {
                    relationships[relationshipName] = ["data": resources.map { $0.identifier }]
                }
            }
            if !relationships.isEmpty {
                data["relationships"] = relationships
            }
        }

        return data
    }

    static func resourceData(attributes: [String: Any], relationships: [String: AnyObject]?) -> Result<Data, XikoloError> {
        do {
            let data = Self.resourceDataObject(attributes: attributes, relationships: relationships)
            let json = ["data": data]
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return .success(jsonData)
        } catch {
            return .failure(.api(.serializationError(.jsonSerializationError(error))))
        }
    }

    func resourceData() -> Result<Data, XikoloError> {
        do {
            var data = Self.resourceDataObject(attributes: self.resourceAttributes(), relationships: self.resourceRelationships())
            if let newResource = self as? ResourceRepresentable, self.objectState != .new {
                data["id"] = newResource.id
            }

            let json = ["data": data]
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return .success(jsonData)
        } catch {
            return .failure(.api(.serializationError(.jsonSerializationError(error))))
        }
    }

    func resourceRelationships() -> [String: AnyObject]? {
        return nil
    }

}
