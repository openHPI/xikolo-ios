//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

class TrackingEventResource: NSObject, NSSecureCoding {

    public static var supportsSecureCoding: Bool { return true }

    var resourceType: String
    var uuid: String

    init(resourceType: TrackingHelper.AnalyticsResourceType, uuid: String) {
        self.resourceType = resourceType.rawValue
        self.uuid = uuid
    }

    required init?(coder decoder: NSCoder) {
        guard let uuid = decoder.decodeObject(of: NSString.self, forKey: "uuid") as String?,
              let type = decoder.decodeObject(of: NSString.self, forKey: "type") as String? else {
            return nil
        }

        self.resourceType = type
        self.uuid = uuid
    }

    func encode(with coder: NSCoder) {
        coder.encode(NSString(string: self.resourceType), forKey: "type")
        coder.encode(NSString(string: self.uuid), forKey: "uuid")
    }

}

extension TrackingEventResource: IncludedPushable {

    func resourceAttributes() -> [String: Any] {
        return [
            "type": self.resourceType,
            "uuid": self.uuid,
        ]
    }

}
