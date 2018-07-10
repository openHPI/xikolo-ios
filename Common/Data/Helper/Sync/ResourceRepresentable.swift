//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Marshal

public typealias ResourceData = MarshaledObject
public typealias JSON = JSONObject
public typealias IncludedPullable = Unmarshaling

public protocol ResourceTypeRepresentable {
    static var type: String { get }
}

public protocol ResourceIdRepresentable {
    var id: String { get set }
}

public protocol ResourceRepresentable: ResourceTypeRepresentable, ResourceIdRepresentable {
    var identifier: [String: String] { get }
}

extension ResourceRepresentable {

    public var identifier: [String: String] {
        return [
            "type": Self.type,
            "id": self.id,
        ]
    }

}
