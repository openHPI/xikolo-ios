//
//  Created for schulcloud-mobile-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Marshal
import Result

public protocol SyncStrategy {

    var resourceKeyAttribute: String { get }

    func queryItems<Query>(forQuery query: Query) -> [URLQueryItem] where Query: ResourceQuery
    func validateResourceData(_ resourceData: MarshalDictionary) -> Result<Void, SyncError>
    func validateObjectCreation(object: ResourceData, toHaveType expectedType: String) throws

    func extractResourceData(from object: ResourceData) throws -> ResourceData
    func extractResourceData(from object: ResourceData) throws -> [ResourceData]

    func extractIncludedResourceData(from object: ResourceData) -> [ResourceData]
    func findIncludedObject(forKey key: KeyType,
                            ofObject object: ResourceData,
                            with context: SynchronizationContext) -> FindIncludedObjectResult
    func findIncludedObjects(forKey key: KeyType,
                             ofObject object: ResourceData,
                             with context: SynchronizationContext) -> FindIncludedObjectsResult

    func resourceData(for resource: Pushable) -> Result<Data, SyncError>

}

public enum FindIncludedObjectResult {
    case notExisting
    case id(String)
    case object(String, ResourceData)
}

public enum FindIncludedObjectsResult {
    case notExisting
    case included(objects: [(id: String, object: ResourceData)], ids: [String])
}
