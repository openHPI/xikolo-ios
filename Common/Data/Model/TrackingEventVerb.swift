//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

class TrackingEventVerb: NSObject, NSSecureCoding {

    public static var supportsSecureCoding: Bool { return true }

    var type: String

    required init(type: String) {
        self.type = type
    }

    required init?(coder decoder: NSCoder) {
        guard let type = decoder.decodeObject(of: NSString.self, forKey: "type") as String? else {
            return nil
        }

        self.type = type
    }

    func encode(with coder: NSCoder) {
        coder.encode(NSString(string: self.type), forKey: "type")
    }

}

extension TrackingEventVerb: IncludedPushable {

    func resourceAttributes() -> [String: Any] {
        return ["type": self.type]
    }

}
