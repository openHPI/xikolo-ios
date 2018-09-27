//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

public protocol ResourceQuery {
    associatedtype Resource: ResourceTypeRepresentable

    var resourceType: Resource.Type { get }
    var filters: [String: Any?] { get set }
    var includes: [String] { get set }

    mutating func addFilter(forKey key: String, withValue value: Any?)
    mutating func include(_ key: String)

    func resourceURL(relativeTo baseURL: URL) -> URL?
}

extension ResourceQuery {
    public mutating func addFilter(forKey key: String, withValue value: Any?) {
        self.filters[key] = value
    }

    public mutating func include(_ key: String) {
        self.includes.append(key)
    }
}

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
