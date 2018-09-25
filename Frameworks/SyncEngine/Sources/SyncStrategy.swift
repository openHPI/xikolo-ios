//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Marshal
import Result

// TODO: move to PULLABLE
public protocol SyncStrategy {

    var resourceKeyAttribute: String { get }

    func queryItems<Query>(forQuery query: Query) -> [URLQueryItem] where Query: ResourceQuery
    func validateResourceData(_ resourceData: MarshalDictionary) -> Result<Void, SyncError>
    func validateObjectCreation(object: ResourceData, toHaveType expectedType: String) throws

    func extractResourceData(from object: ResourceData) throws -> ResourceData
    func extractResourceData(from object: ResourceData) throws -> [ResourceData]

    func extractIncludedResourceData(from object: ResourceData) -> [ResourceData]

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
