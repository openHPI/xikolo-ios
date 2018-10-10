//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public protocol SyncEngineResult {
    var headers: [AnyHashable: Any] { get }
}

public struct SyncMultipleResult: SyncEngineResult {
    public let objectIds: [NSManagedObjectID]
    public let headers: [AnyHashable: Any]
}

public struct SyncSingleResult: SyncEngineResult {
    public let objectId: NSManagedObjectID
    public let headers: [AnyHashable: Any]
}

struct MergeMultipleResult<Resource> where Resource: NSManagedObject & Pullable {
    let resources: [Resource]
    let headers: [AnyHashable: Any]
}

struct MergeSingleResult<Resource> where Resource: NSManagedObject & Pullable {
    let resource: Resource
    let headers: [AnyHashable: Any]
}

struct NetworkResult: SyncEngineResult {
    let resourceData: ResourceData
    let headers: [AnyHashable: Any]
}
