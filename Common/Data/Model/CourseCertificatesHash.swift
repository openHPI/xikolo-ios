//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public final class CourseCertificatesHash: NSObject, NSCoding, IncludedPullable {

    public var available: Bool
    public var threshold: Int32?

    public required init(object: ResourceData) throws {
        self.available = try object.value(for: "available")
        self.threshold = try object.value(for: "threshold")
    }

    public required init(coder decoder: NSCoder) {
        available = decoder.decodeBool(forKey: "available")
        threshold = decoder.decodeObject(forKey: "threshold") as? Int32
    }

    public func encode(with coder: NSCoder) {
        coder.encode(available, forKey: "available")
        coder.encode(threshold, forKey: "threshold")
    }

}
