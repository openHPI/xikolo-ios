//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

protocol ResourceURLRepresentable {
    func resourceURL(relativeTo baseURL: URL) -> URL?
}

protocol ResourceQuery: ResourceURLRepresentable {
    associatedtype Resource

    var resourceType: Resource.Type { get }
    var filters: [String: Any?] { get set }
    var includes: [String] { get set }

    mutating func addFilter(forKey key: String, withValue value: Any?)
    mutating func include(_ key: String)

    func resourceURL(relativeTo baseURL: URL) -> URL?
}

extension ResourceQuery {
    mutating func addFilter(forKey key: String, withValue value: Any?) {
        self.filters[key] = value
    }

    mutating func include(_ key: String) {
        self.includes.append(key)
    }
}

struct SingleResourceQuery<Resource> : ResourceQuery where Resource: ResourceRepresentable {

    let id: String
    let resourceType: Resource.Type
    var filters: [String: Any?] = [:]
    var includes: [String] = []

    init(resource: Resource) {
        self.id = resource.id
        self.resourceType = Resource.self
    }

    init(type: Resource.Type, id: String) {
        self.id = id
        self.resourceType = type
    }

    func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.resourceType.type).appendingPathComponent(self.id)
    }

}

struct MultipleResourcesQuery<Resource> : ResourceQuery where Resource: ResourceTypeRepresentable {

    let resourceType: Resource.Type
    var filters: [String: Any?] = [:]
    var includes: [String] = []

    init(type: Resource.Type) {
        self.resourceType = type
    }

    func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.resourceType.type)
    }

}

struct RawSingleResourceQuery: ResourceURLRepresentable {
    let type: String
    let id: String

    func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.type).appendingPathComponent(self.id)
    }
}

struct RawMultipleResourcesQuery: ResourceURLRepresentable {
    let type: String

    func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.type)
    }
}
