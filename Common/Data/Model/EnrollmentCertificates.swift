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
        self.confirmationOfParticipation = decoder.decodeObject(of: NSURL.self, forKey: "confirmation_of_participation")?.absoluteURL
        self.recordOfAchievement = decoder.decodeObject(of: NSURL.self, forKey: "record_of_achievement")?.absoluteURL
        self.qualifiedCertificate = decoder.decodeObject(of: NSURL.self, forKey: "qualified_certificate")?.absoluteURL
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.confirmationOfParticipation?.asNSURL(), forKey: "confirmation_of_participation")
        coder.encode(self.recordOfAchievement?.asNSURL(), forKey: "record_of_achievement")
        coder.encode(self.qualifiedCertificate?.asNSURL(), forKey: "qualified_certificate")
    }

}
