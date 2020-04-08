//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public final class EnrollmentCertificates: NSObject, NSSecureCoding, IncludedPullable {

    public static var supportsSecureCoding: Bool { return true }

    public var confirmationOfParticipation: URL?
    public var recordOfAchievement: URL?
    public var qualifiedCertificate: URL?

    public required init(object: ResourceData) throws {
        self.confirmationOfParticipation = try object.failsafeURL(for: "confirmation_of_participation")
        self.recordOfAchievement = try object.failsafeURL(for: "record_of_achievement")
        self.qualifiedCertificate = try object.failsafeURL(for: "qualified_certificate")
    }

    public required init(coder decoder: NSCoder) {
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
