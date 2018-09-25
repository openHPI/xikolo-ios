//
//  Created for schulcloud-mobile-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Marshal

public typealias JsonDictionary = MarshalDictionary
public typealias JsonKey = KeyType
public typealias ResourceData = MarshaledObject
public typealias JSON = JSONObject
public typealias IncludedPullable = Unmarshaling

public protocol ResourceTypeRepresentable {
    static var type: String { get }
}

public protocol ResourceRepresentable: ResourceTypeRepresentable {
    var id: String { get set }

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
