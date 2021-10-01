//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public protocol SyncEngineResult {
    var headers: [AnyHashable: Any] { get }
}

public struct SyncMultipleResult: SyncEngineResult {
    public let oldObjectIds: [NSManagedObjectID]
    public let newObjectIds: [NSManagedObjectID]
    public let headers: [AnyHashable: Any]
}

public struct SyncSingleResult: SyncEngineResult {
    public let objectId: NSManagedObjectID
    public let headers: [AnyHashable: Any]
}

struct MergeMultipleResult<Resource> where Resource: NSManagedObject & Pullable {
    let oldResources: [Resource]
    let newResources: [Resource]
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
