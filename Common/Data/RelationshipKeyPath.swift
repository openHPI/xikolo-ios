//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

/// Describes a relationship key path for a Core Data entity.
public struct RelationshipKeyPath: Hashable {

    /// The destination property name we're observing
    let destinationPropertyName: String

    let destinationEntityName: String

    let relationshipKeyPaths: [String]

    /// The inverse property names of this relationship. Can be used to get the affected object IDs.
    let inverseRelationshipKeyPaths: [String]

    public init(keyPath: String, relationships: [String: NSRelationshipDescription]?) {
        let splittedKeyPath = keyPath.split(separator: ".").map(String.init)

        var destinationEntity: NSEntityDescription?
        var relationships2: [NSRelationshipDescription?] = []
        var inverseRelationship: [NSRelationshipDescription?] = []
        var destinationProperty: NSPropertyDescription?

        var relationshipsByName: [String: NSRelationshipDescription]? = relationships
        var propertiesByName: [String: NSPropertyDescription]? = [:]
        for relationshipName in splittedKeyPath {
            if let relationship = relationshipsByName?[relationshipName] {
                destinationEntity = relationship.destinationEntity
                relationships2.append(relationship)
                inverseRelationship.append(relationship.inverseRelationship)
                relationshipsByName = relationship.destinationEntity?.relationshipsByName
                propertiesByName = relationship.destinationEntity?.propertiesByName
            } else if let property = propertiesByName?[relationshipName] {
                destinationProperty = property
            } else {
                assertionFailure("Invalid key path is used")
            }
        }

        self.destinationEntityName = destinationEntity?.name ?? ""
        self.destinationPropertyName = destinationProperty?.name ?? ""
        self.relationshipKeyPaths = relationships2.map { $0?.name ?? "" }
        self.inverseRelationshipKeyPaths = inverseRelationship.map { $0?.name ?? "" }

        assert(!self.destinationEntityName.isEmpty, "Invalid key path is used")
        self.relationshipKeyPaths.forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
        self.inverseRelationshipKeyPaths.forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
    }

}
