//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public final class EnrollmentCertificates: NSObject, NSCoding, IncludedPullable {

    public var confirmationOfParticipation: URL?
    public var recordOfAchievement: URL?
    public var qualifiedCertificate: URL?

    required public init(object: ResourceData) throws {
        self.confirmationOfParticipation = try object.value(for: "confirmation_of_participation")
        self.recordOfAchievement = try object.value(for: "record_of_achievement")
        self.qualifiedCertificate = try object.value(for: "qualified_certificate")
    }

    required public init(coder decoder: NSCoder) {
        self.confirmationOfParticipation = decoder.decodeObject(forKey: "confirmation_of_participation") as? URL
        self.recordOfAchievement = decoder.decodeObject(forKey: "record_of_achievement") as? URL
        self.qualifiedCertificate = decoder.decodeObject(forKey: "qualified_certificate") as? URL
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.confirmationOfParticipation, forKey: "confirmation_of_participation")
        coder.encode(self.recordOfAchievement, forKey: "record_of_achievement")
        coder.encode(self.qualifiedCertificate, forKey: "qualified_certificate")
    }

}
