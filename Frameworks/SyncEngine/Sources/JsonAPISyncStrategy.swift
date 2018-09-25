//
//  Created for schulcloud-mobile-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Marshal
import Result

public struct JsonAPISyncStrategy: SyncStrategy {

    public init() {
        
    }

    public var resourceKeyAttribute: String {
        return "id"
    }

    public func queryItems<Query>(forQuery query: Query) -> [URLQueryItem] where Query: ResourceQuery {
        var queryItems: [URLQueryItem] = []

        // includes
        if !query.includes.isEmpty {
            queryItems.append(URLQueryItem(name: "include", value: query.includes.joined(separator: ",")))
        }

        // filters
        for (key, value) in query.filters {
            let stringValue: String
            if let valueArray = value as? [Any] {
                stringValue = valueArray.map { String(describing: $0) }.joined(separator: ",")
            } else if let value = value {
                stringValue = String(describing: value)
            } else {
                stringValue = "null"
            }

            let queryItem = URLQueryItem(name: "filter[\(key)]", value: stringValue)
            queryItems.append(queryItem)
        }

        return queryItems
    }

    public func validateResourceData(_ resourceData: MarshalDictionary) -> Result<Void, SyncError> {
        // JSON:API validation
        let hasData = resourceData["data"] != nil
        let hasError = resourceData["error"] != nil
        let hasMeta = resourceData["meta"] != nil

        guard hasData || hasError || hasMeta else {
            return .failure(.api(.serialization(.topLevelEntryMissing)))
        }

        guard hasError && !hasData || !hasError && hasData else {
            return .failure(.api(.serialization(.topLevelDataAndErrorsCoexist)))
        }

        guard !hasError else {
            if let errorMessage = resourceData["error"] as? String {
                return .failure(.api(.serverError(message: errorMessage)))
            } else {
                return .failure(.api(.unknownServerError))
            }
        }

        return .success(())
    }

    public func validateObjectCreation(object: ResourceData, toHaveType expectedType: String) throws {
        let resourceType = try object.value(for: "type") as String
        if resourceType != expectedType {
            throw SerializationError.resourceTypeMismatch(expected: expectedType, found: resourceType)
        }
    }

    public func extractResourceData(from object: ResourceData) throws -> ResourceData {
        return try object.value(for: "data")
    }

    public func extractResourceData(from object: ResourceData) throws -> [ResourceData] {
        return try object.value(for: "data")
    }

    public func extractIncludedResourceData(from object: ResourceData) -> [ResourceData] {
        let includes = try? object.value(for: "included") as [ResourceData]
        return includes ?? []
    }

    public func resourceData(for resource: Pushable) -> Result<Data, SyncError> {
        do {
            var data: [String: Any] = [ "type": type(of: resource).type ]
            if let newResource = self as? ResourceRepresentable, resource.objectState != .new {
                data["id"] = newResource.id
            }

            data["attributes"] = resource.resourceAttributes()
            if let resourceRelationships = resource.resourceRelationships() {
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

            let json = ["data": data]
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return .success(jsonData)
        } catch {
            return .failure(.api(.serialization(.jsonSerialization(error))))
        }
    }

}
