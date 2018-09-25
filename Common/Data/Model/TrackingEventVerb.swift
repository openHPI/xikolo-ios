//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import SyncEngine

class TrackingEventVerb: NSObject, NSCoding {

    var type: String

    required init(type: String) {
        self.type = type
    }

    required init?(coder decoder: NSCoder) {
        guard let type = decoder.decodeObject(forKey: "type") as? String else {
            return nil
        }

        self.type = type
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.type, forKey: "type")
    }

}

extension TrackingEventVerb: IncludedPushable {

    func resourceAttributes() -> [String: Any] {
        return ["type": self.type]
    }

}
