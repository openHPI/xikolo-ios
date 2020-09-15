//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

/// Describes a relationship key path for a Core Data entity.
public struct RelationshipKeyPath: Hashable {

    /// The destination property name we're observing
    let destinationPropertyName: String

    /// The destination entity name we're observing
    let destinationEntityName: String

    /// The property names of this relationship
    let relationshipKeyPaths: [String]

    /// The inverse property names of this relationship. Can be used to get the affected objects.
    let inverseRelationshipKeyPaths: [String]

    public init(keyPath: String, relationships initialRelationshipsByName: [String: NSRelationshipDescription]?) {
        let keyPathSplit = keyPath.split(separator: ".").map(String.init)

        var lastDestinationEntity: NSEntityDescription?
        var lastDestinationProperty: NSPropertyDescription?
        var relationships: [NSRelationshipDescription?] = []
        var inverseRelationships: [NSRelationshipDescription?] = []

        var relationshipsByName: [String: NSRelationshipDescription]? = initialRelationshipsByName
        var propertiesByName: [String: NSPropertyDescription]? = [:]

        for relationshipName in keyPathSplit {
            if let relationship = relationshipsByName?[relationshipName] {
                lastDestinationEntity = relationship.destinationEntity
                relationships.append(relationship)
                inverseRelationships.append(relationship.inverseRelationship)
                relationshipsByName = relationship.destinationEntity?.relationshipsByName
                propertiesByName = relationship.destinationEntity?.propertiesByName
            } else if let property = propertiesByName?[relationshipName] {
                lastDestinationProperty = property
            } else {
                assertionFailure("Invalid key path is used")
            }
        }

        self.destinationEntityName = lastDestinationEntity?.name ?? ""
        self.destinationPropertyName = lastDestinationProperty?.name ?? ""
        self.relationshipKeyPaths = relationships.map { $0?.name ?? "" }
        self.inverseRelationshipKeyPaths = inverseRelationships.map { $0?.name ?? "" }

        assert(!self.destinationEntityName.isEmpty, "Invalid key path is used")
        self.relationshipKeyPaths.forEach { property in assert(!property.isEmpty, "Invalid key path is used") }
        self.inverseRelationshipKeyPaths.forEach { property in assert(!property.isEmpty, "Invalid key path is used") }
    }

}
