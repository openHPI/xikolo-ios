//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

class TrackingEventUser: NSObject, NSSecureCoding {

    public static var supportsSecureCoding: Bool { return true }

    var uuid: String

    init(uuid: String) {
        self.uuid = uuid
        super.init()
    }

    required init?(coder decoder: NSCoder) {
        guard let uuid = decoder.decodeObject(of: NSString.self, forKey: "uuid") as String? else {
            return nil
        }

        self.uuid = uuid

    }

    func encode(with coder: NSCoder) {
        coder.encode(NSString(string: self.uuid), forKey: "uuid")
    }

}

extension TrackingEventUser: IncludedPushable {

    func resourceAttributes() -> [String: Any] {
        return [ "uuid": self.uuid ]
    }

}
