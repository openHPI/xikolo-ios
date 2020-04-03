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
