//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Result

public enum ObjectState: Int16 {
    case unchanged = 0
    case new
    case modified
    case deleted
}

public protocol IncludedPushable {
    func resourceAttributes() -> [String: Any]
}

public protocol Pushable: ResourceTypeRepresentable, IncludedPushable, NSFetchRequestResult {
    var objectState: ObjectState { get }

    static func resourceDataObject(attributes: [String: Any], relationships: [String: AnyObject]?) -> [String: Any]
    static func resourceData(attributes: [String: Any], relationships: [String: AnyObject]?) -> Result<Data, SyncError>

    func resourceRelationships() -> [String: AnyObject]?
    func markAsUnchanged()
}

public extension Pushable {

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

    static func resourceData(attributes: [String: Any], relationships: [String: AnyObject]?) -> Result<Data, SyncError> {
        do {
            let data = Self.resourceDataObject(attributes: attributes, relationships: relationships)
            let json = ["data": data]
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return .success(jsonData)
        } catch {
            return .failure(.api(.serialization(.jsonSerialization(error))))
        }
    }

    func resourceRelationships() -> [String: AnyObject]? {
        return nil
    }

}
