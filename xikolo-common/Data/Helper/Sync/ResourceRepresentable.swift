//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Marshal

typealias ResourceData = MarshaledObject
typealias JSON = JSONObject
typealias IncludedPullable = Unmarshaling

protocol ResourceTypeRepresentable {
    static var type: String { get }
}

protocol ResourceRepresentable: ResourceTypeRepresentable {
    var id: String { get set }

    var identifier: [String: String] { get }
}

extension ResourceRepresentable {

    var identifier: [String: String] {
        return [
            "type": Self.type,
            "id": self.id,
        ]
    }

}
