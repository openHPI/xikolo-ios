//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

public struct MultipleResourcesQuery<Resource>: ResourceQuery where Resource: ResourceTypeRepresentable {

    public let resourceType: Resource.Type
    public var filters: [String: Any?] = [:]
    public var includes: [String] = []

    public init(type: Resource.Type) {
        self.resourceType = type
    }

    public func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.resourceType.type)
    }

}
