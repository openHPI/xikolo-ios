//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public protocol JSONAPIPushable: Pushable, JSONAPIValidatable { }

extension JSONAPIPushable {

    public func resourceData() -> Result<Data, SyncError> {
        do {
            var data: [String: Any] = [ "type": Self.type ]
            if let newResource = self as? ResourceRepresentable, let managedObject = self as? (Pushable & NSManagedObject), managedObject.objectState != .new {
                data["id"] = newResource.id
            }

            data["attributes"] = self.resourceAttributes()
            if let resourceRelationships = self.resourceRelationships() {
                var relationships: [String: Any] = [:]
                for (relationshipName, object) in resourceRelationships {
                    if let resource = object as? ResourceRepresentable {
                        relationships[relationshipName] = ["data": resource.identifier]
                    } else if let resources = object as? [ResourceRepresentable] {
                        relationships[relationshipName] = ["data": resources.map(\.identifier)]
                    }
                }

                if !relationships.isEmpty {
                    data["relationships"] = relationships
                }
            }

            let json = ["data": data]
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return .success(jsonData)
        } catch {
            return .failure(.api(.serialization(.jsonSerialization(error))))
        }
    }

    public static func resourceData(attributes: [String: Any], relationships: [String: AnyObject]?) -> Result<Data, SyncError> {
        do {
            let data = Self.resourceDataObject(attributes: attributes, relationships: relationships)
            let json = ["data": data]
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return .success(jsonData)
        } catch {
            return .failure(.api(.serialization(.jsonSerialization(error))))
        }
    }

    private static func resourceDataObject(attributes: [String: Any], relationships: [String: AnyObject]?) -> [String: Any] {
        var data: [String: Any] = [ "type": Self.type ]

        data["attributes"] = attributes
        if let resourceRelationships = relationships {
            var relationships: [String: Any] = [:]
            for (relationshipName, object) in resourceRelationships {
                if let resource = object as? ResourceRepresentable {
                    relationships[relationshipName] = ["data": resource.identifier]
                } else if let resources = object as? [ResourceRepresentable] {
                    relationships[relationshipName] = ["data": resources.map(\.identifier)]
                }
            }

            if !relationships.isEmpty {
                data["relationships"] = relationships
            }
        }

        return data
    }

}

private extension ResourceRepresentable {

    var identifier: [String: String] {
        return [
            "type": Self.type,
            "id": self.id,
        ]
    }

}
