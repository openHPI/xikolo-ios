//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

public struct SingleResourceQuery<Resource>: ResourceQuery where Resource: ResourceRepresentable {

    let id: String
    public let resourceType: Resource.Type
    public var filters: [String: Any?] = [:]
    public var includes: [String] = []

    public init(resource: Resource) {
        self.id = resource.id
        self.resourceType = Resource.self
    }

    public init(type: Resource.Type, id: String) {
        self.id = id
        self.resourceType = type
    }

    public func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.resourceType.type).appendingPathComponent(self.id)
    }

}
