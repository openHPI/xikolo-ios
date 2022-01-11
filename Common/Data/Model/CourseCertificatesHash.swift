//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public final class CourseCertificatesHash: NSObject, NSSecureCoding, IncludedPullable {

    public static var supportsSecureCoding: Bool { return true }

    public var available: Bool
    public var threshold: Int?

    public required init(object: ResourceData) throws {
        self.available = try object.value(for: "available")
        self.threshold = try object.value(for: "threshold")
    }

    public required init(coder decoder: NSCoder) {
        self.available = decoder.decodeBool(forKey: "available")
        self.threshold = decoder.decodeObject(of: NSNumber.self, forKey: "threshold")?.intValue
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.available, forKey: "available")
        coder.encode(self.threshold.map(NSNumber.init(value:)), forKey: "threshold")
    }

}
