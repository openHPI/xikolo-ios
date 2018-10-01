//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Marshal

public protocol JSONAPIPullable: Pullable, JSONAPIValidatable { }

extension JSONAPIPullable {

    public static var resourceKeyAttribute: String {
        return "id"
    }

    public static func queryItems<Query>(forQuery query: Query) -> [URLQueryItem] where Query: ResourceQuery {
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

    public static func validateObjectCreation(object: ResourceData) throws {
        let resourceType = try object.value(for: "type") as String
        if resourceType != Self.type {
            throw SerializationError.resourceTypeMismatch(expected: Self.type, found: resourceType)
        }
    }

    public static func extractResourceData(from object: ResourceData) throws -> ResourceData {
        return try object.value(for: "data")
    }

    public static func extractResourceData(from object: ResourceData) throws -> [ResourceData] {
        return try object.value(for: "data")
    }

    public static func extractIncludedResourceData(from object: ResourceData) -> [ResourceData] {
        let includes = try? object.value(for: "included") as [ResourceData]
        return includes ?? []
    }

}
