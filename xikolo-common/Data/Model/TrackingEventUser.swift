//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

class TrackingEventUser : NSObject, NSCoding {

    var uuid: String

    init(uuid: String) {
        self.uuid = uuid
        super.init()
    }

    required init?(coder decoder: NSCoder) {
        guard let uuid = decoder.decodeObject(forKey: "uuid") as? String else {
            return nil
        }

        self.uuid = uuid
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.uuid, forKey: "uuid")
    }

}

extension TrackingEventUser : IncludedPushable {

    func resourceAttributes() -> [String : Any] {
        return [ "uuid": self.uuid ]
    }

}
